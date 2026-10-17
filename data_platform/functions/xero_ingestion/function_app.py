import os
import json
import time
import logging
import requests
import pyodbc
from datetime import datetime
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

KEY_VAULT_URL = "https://css-key-vault-weu.vault.azure.net"
CLIENT_ID = "CED8D5BF878C44369F613AD78407C065"
TENANT_ID = "d4710e18-0731-4f44-a828-e76f11d1b6ea"
SQL_SERVER = "css-sql-prd-neu.database.windows.net"


def get_key_vault_client():
    return SecretClient(vault_url=KEY_VAULT_URL, credential=DefaultAzureCredential())


def refresh_xero_token(kv_client):
    client_secret = kv_client.get_secret("xero-client-secret").value
    refresh_token = kv_client.get_secret("xero-refresh-token").value

    res = requests.post(
        "https://identity.xero.com/connect/token",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        data={
            "grant_type": "refresh_token",
            "client_id": CLIENT_ID,
            "client_secret": client_secret,
            "refresh_token": refresh_token
        }
    )
    res.raise_for_status()
    payload = res.json()
    kv_client.set_secret("xero-refresh-token", payload["refresh_token"])
    return payload["access_token"]


def get_sql_connection(db_name, retries=3, delay=60):
    conn_str = (
        f"Driver={{ODBC Driver 18 for SQL Server}};"
        f"Server=tcp:{SQL_SERVER},1433;"
        f"Database={db_name};"
        f"Authentication=ActiveDirectoryMsi;"
        f"Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
    )
    for attempt in range(retries):
        try:
            return pyodbc.connect(conn_str)
        except pyodbc.OperationalError:
            if attempt < retries - 1:
                logging.info(f"Database sleeping. Retrying in {delay}s...")
                time.sleep(delay)
            else:
                raise


def get_watermark(cursor, table_name):
    query = """
    SELECT COALESCE(DATEADD(hour, -1, MAX(last_refresh_utc)), DATEADD(day, -30, SYSUTCDATETIME()))
    FROM [meta].[refresh_metadata]
    WHERE table_name = ?
    """
    cursor.execute(query, table_name)
    row = cursor.fetchone()
    return row[0].strftime("%Y, %m, %d, %H, %M, %S") if row and row[0] else None


def fetch_xero_pages(endpoint, access_token, watermark_str=None, paginate=True):
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Xero-Tenant-Id": TENANT_ID,
        "Accept": "application/json"
    }
    records, page = [], 1

    while True:
        params = {}
        if paginate:
            params["page"] = page
        if watermark_str:
            params["where"] = f"UpdatedDateUTC>=DateTime({watermark_str})"

        resp = requests.get(f"https://api.xero.com/api.xro/2.0/{endpoint}", headers=headers, params=params)
        if resp.status_code == 429:
            retry_after = int(resp.headers.get("Retry-After", 60))
            time.sleep(retry_after + 1)
            continue

        resp.raise_for_status()
        data = resp.json().get(endpoint, [])
        if not data:
            break

        records.extend(data)
        if not paginate:
            break
        page += 1

    return records


@app.route(route="sync_xero_finance", methods=["POST"])
def sync_xero_finance(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Starting Xero Finance ingestion.")

    # Read target DB dynamically from ADF payload (defaults to dev if missing)
    try:
        req_body = req.get_json()
        target_db = req_body.get("dwh_db_name", "css-dwh-dev")
    except ValueError:
        target_db = "css-dwh-dev"

    try:
        kv_client = get_key_vault_client()
        access_token = refresh_xero_token(kv_client)
        conn = get_sql_connection(target_db)
        cursor = conn.cursor()

        # 1. Ingest Invoices
        inv_watermark = get_watermark(cursor, "raw_xero.Invoices")
        invoices = fetch_xero_pages("Invoices", access_token, inv_watermark, paginate=True)
        for inv in invoices:
            cursor.execute("""
                MERGE raw_xero.Invoices AS target
                USING (SELECT ? AS InvoiceID) AS source ON target.InvoiceID = source.InvoiceID
                WHEN MATCHED THEN
                    UPDATE SET InvoiceNumber = ?, Reference = ?, Type = ?, Status = ?, 
                               InvoiceDate = ?, DueDate = ?, SubTotal = ?, TotalTax = ?, 
                               Total = ?, AmountDue = ?, AmountPaid = ?, AmountCredited = ?, 
                               CurrencyCode = ?, CurrencyRate = ?, UpdatedDateUTC = ?, 
                               ContactID = ?, ContactName = ?, LineItems = ?
                WHEN NOT MATCHED THEN
                    INSERT (InvoiceID, InvoiceNumber, Reference, Type, Status, InvoiceDate, DueDate, 
                            SubTotal, TotalTax, Total, AmountDue, AmountPaid, AmountCredited, 
                            CurrencyCode, CurrencyRate, UpdatedDateUTC, ContactID, ContactName, LineItems)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """, (
                inv.get("InvoiceID"), inv.get("InvoiceNumber"), inv.get("Reference"), inv.get("Type"), inv.get("Status"),
                inv.get("DateString"), inv.get("DueDateString"), inv.get("SubTotal"), inv.get("TotalTax"),
                inv.get("Total"), inv.get("AmountDue"), inv.get("AmountPaid"), inv.get("AmountCredited"),
                inv.get("CurrencyCode"), inv.get("CurrencyRate"), inv.get("UpdatedDateUTC"),
                inv.get("Contact", {}).get("ContactID"), inv.get("Contact", {}).get("Name"), json.dumps(inv.get("LineItems", [])),
                inv.get("InvoiceID"), inv.get("InvoiceNumber"), inv.get("Reference"), inv.get("Type"), inv.get("Status"),
                inv.get("DateString"), inv.get("DueDateString"), inv.get("SubTotal"), inv.get("TotalTax"),
                inv.get("Total"), inv.get("AmountDue"), inv.get("AmountPaid"), inv.get("AmountCredited"),
                inv.get("CurrencyCode"), inv.get("CurrencyRate"), inv.get("UpdatedDateUTC"),
                inv.get("Contact", {}).get("ContactID"), inv.get("Contact", {}).get("Name"), json.dumps(inv.get("LineItems", []))
            ))
        cursor.execute("EXEC [meta].[usp_log_refresh] @table_name = 'raw_xero.Invoices'")
        conn.commit()

        # 2. Ingest Bank Transactions
        bt_watermark = get_watermark(cursor, "raw_xero.BankTransactions")
        transactions = fetch_xero_pages("BankTransactions", access_token, bt_watermark, paginate=True)
        for tx in transactions:
            cursor.execute("""
                MERGE raw_xero.BankTransactions AS target
                USING (SELECT ? AS BankTransactionID) AS source ON target.BankTransactionID = source.BankTransactionID
                WHEN MATCHED THEN
                    UPDATE SET Type = ?, ContactID = ?, ContactName = ?, BankAccountCode = ?, 
                               BankAccountName = ?, Date = ?, Reference = ?, CurrencyCode = ?, 
                               CurrencyRate = ?, SubTotal = ?, TotalTax = ?, Total = ?, 
                               Status = ?, UpdatedDateUTC = ?, LineItems = ?
                WHEN NOT MATCHED THEN
                    INSERT (BankTransactionID, Type, ContactID, ContactName, BankAccountCode, 
                            BankAccountName, Date, Reference, CurrencyCode, CurrencyRate, 
                            SubTotal, TotalTax, Total, Status, UpdatedDateUTC, LineItems)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """, (
                tx.get("BankTransactionID"), tx.get("Type"), tx.get("Contact", {}).get("ContactID"), tx.get("Contact", {}).get("Name"),
                tx.get("BankAccount", {}).get("Code"), tx.get("BankAccount", {}).get("Name"), tx.get("DateString"),
                tx.get("Reference"), tx.get("CurrencyCode"), tx.get("CurrencyRate"), tx.get("SubTotal"), tx.get("TotalTax"),
                tx.get("Total"), tx.get("Status"), tx.get("UpdatedDateUTC"), json.dumps(tx.get("LineItems", [])),
                tx.get("BankTransactionID"), tx.get("Type"), tx.get("Contact", {}).get("ContactID"), tx.get("Contact", {}).get("Name"),
                tx.get("BankAccount", {}).get("Code"), tx.get("BankAccount", {}).get("Name"), tx.get("DateString"),
                tx.get("Reference"), tx.get("CurrencyCode"), tx.get("CurrencyRate"), tx.get("SubTotal"), tx.get("TotalTax"),
                tx.get("Total"), tx.get("Status"), tx.get("UpdatedDateUTC"), json.dumps(tx.get("LineItems", []))
            ))
        cursor.execute("EXEC [meta].[usp_log_refresh] @table_name = 'raw_xero.BankTransactions'")
        conn.commit()

        # 3. Ingest Accounts (Accounts endpoint in Xero does not use ?page= pagination)
        accounts = fetch_xero_pages("Accounts", access_token, paginate=False)
        for acc in accounts:
            cursor.execute("""
                MERGE raw_xero.Accounts AS target
                USING (SELECT ? AS AccountID) AS source ON target.AccountID = source.AccountID
                WHEN MATCHED THEN
                    UPDATE SET Code = ?, Name = ?, Type = ?, Class = ?, Status = ?, UpdatedDateUTC = ?
                WHEN NOT MATCHED THEN
                    INSERT (AccountID, Code, Name, Type, Class, Status, UpdatedDateUTC)
                    VALUES (?, ?, ?, ?, ?, ?, ?);
            """, (
                acc.get("AccountID"), acc.get("Code"), acc.get("Name"), acc.get("Type"), acc.get("Class"), acc.get("Status"), acc.get("UpdatedDateUTC"),
                acc.get("AccountID"), acc.get("Code"), acc.get("Name"), acc.get("Type"), acc.get("Class"), acc.get("Status"), acc.get("UpdatedDateUTC")
            ))
        cursor.execute("EXEC [meta].[usp_log_refresh] @table_name = 'raw_xero.Accounts'")
        conn.commit()

        cursor.close()
        conn.close()

        return func.HttpResponse(
            body=json.dumps({"status": "success", "message": "Xero ingestion completed"}),
            status_code=200,
            mimetype="application/json"
        )
    except Exception as ex:
        logging.error(f"Xero sync failed: {str(ex)}")
        return func.HttpResponse(
            body=json.dumps({"status": "error", "error": str(ex)}),
            status_code=500,
            mimetype="application/json"
        )