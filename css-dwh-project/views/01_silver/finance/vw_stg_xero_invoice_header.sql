CREATE
-- OR ALTER
VIEW [stg].[xero_invoice_header] AS
SELECT
    inv.InvoiceID AS invoice_id,
    inv.InvoiceNumber AS invoice_number,
    inv.[Reference] AS [reference],
    inv.[Type] AS [type],
    inv.[Status] AS [status],
    TRY_CAST(inv.InvoiceDate AS DATE) AS invoice_date, -- already a plain ISO date string, not the /Date(...)/ epoch format
    TRY_CAST(inv.DueDate AS DATE) AS due_date, -- already a plain ISO date string, not the /Date(...)/ epoch format
    CAST(inv.SubTotal AS DECIMAL(18, 2)) AS sub_total,
    CAST(inv.TotalTax AS DECIMAL(18, 2)) AS total_tax,
    CAST(inv.Total AS DECIMAL(18, 2)) AS total,
    CAST(inv.AmountDue AS DECIMAL(18, 2)) AS amount_due,
    CAST(inv.AmountPaid AS DECIMAL(18, 2)) AS amount_paid,
    CAST(inv.AmountCredited AS DECIMAL(18, 2)) AS amount_credited,
    inv.CurrencyCode AS currency_code,
    inv.CurrencyRate AS currency_rate,
    dbo.fn_ParseXeroEpochDate(inv.UpdatedDateUTC) AS updated_date_utc,
    inv.ContactID AS contact_id,
    inv.ContactName AS contact_name
FROM
    raw_xero.Invoices AS inv;
