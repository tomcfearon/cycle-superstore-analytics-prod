CREATE
-- OR ALTER
VIEW [stg].[xero_invoice_details] AS
SELECT
    inv.InvoiceID AS invoice_id,
    li.LineItemID AS line_item_id,
    li.[Description] AS [description],
    CAST(li.Quantity AS DECIMAL(18, 4)) AS quantity,
    CAST(li.UnitAmount AS DECIMAL(18, 4)) AS unit_amount,
    li.TaxType AS tax_type,
    CAST(li.TaxAmount AS DECIMAL(18, 2)) AS tax_amount,
    CAST(li.LineAmount AS DECIMAL(18, 2)) AS line_amount,
    li.AccountCode AS account_code
FROM
    raw_xero.Invoices AS inv
    CROSS APPLY OPENJSON(inv.LineItems)
        WITH (
            LineItemID    VARCHAR(50)     '$.LineItemID',
            [Description] NVARCHAR(MAX)   '$.Description',
            Quantity      DECIMAL(18, 4)  '$.Quantity',
            UnitAmount    DECIMAL(18, 4)  '$.UnitAmount',
            TaxType       VARCHAR(50)     '$.TaxType',
            TaxAmount     DECIMAL(18, 2)  '$.TaxAmount',
            LineAmount    DECIMAL(18, 2)  '$.LineAmount',
            AccountCode   VARCHAR(50)     '$.AccountCode'
        ) AS li;
