CREATE VIEW -- OR ALTER
[stg].[xero_bank_transaction_header]
AS
WITH   deduped
AS     (SELECT bt.BankTransactionID,
               bt.[Type],
               bt.ContactID,
               bt.ContactName,
               bt.BankAccountCode,
               bt.BankAccountName,
               bt.[Date],
               bt.[Reference],
               bt.CurrencyCode,
               bt.CurrencyRate,
               bt.SubTotal,
               bt.TotalTax,
               bt.Total,
               bt.[Status],
               bt.UpdatedDateUTC,
               ROW_NUMBER() OVER (PARTITION BY bt.BankTransactionID ORDER BY dbo.fn_ParseXeroEpochDate(bt.UpdatedDateUTC) DESC) AS rn
        FROM   raw_xero.BankTransactions AS bt)
SELECT BankTransactionID AS bank_transaction_id,
       [Type] AS [type],
       ContactID AS contact_id,
       ContactName AS contact_name,
       BankAccountCode AS bank_account_code,
       BankAccountName AS bank_account_name,
       TRY_CAST ([Date] AS DATE) AS transaction_date, -- plain ISO date string, not the epoch format
       [Reference] AS [reference],
       CurrencyCode AS currency_code,
       CAST (CurrencyRate AS DECIMAL (18, 2)) AS currency_rate,
       CAST (SubTotal AS DECIMAL (18, 2)) AS sub_total,
       CAST (TotalTax AS DECIMAL (18, 2)) AS total_tax,
       CAST (Total AS DECIMAL (18, 2)) AS total,
       [Status] AS [status],
       dbo.fn_ParseXeroEpochDate(UpdatedDateUTC) AS updated_date_utc
FROM   deduped
WHERE  rn = 1;