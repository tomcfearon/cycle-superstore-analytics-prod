CREATE --OR ALTER
 VIEW 
[int].[xero_invoices]
AS
SELECT CASE h.[type] WHEN 'ACCREC' THEN 'Receivable' WHEN 'ACCPAY' THEN 'Payable' ELSE h.[type] END AS invoice_type,
       h.[status],
       h.invoice_date,
       h.due_date,
       h.sub_total,
       h.total_tax,
       h.total,
       h.amount_due,
       h.amount_paid,
       h.amount_credited,
       h.currency_code,
       CAST (h.currency_rate AS DECIMAL (18, 2)) AS currency_rate,
       h.updated_date_utc,
       h.contact_name,
       d.[description],
       d.quantity,
       d.unit_amount,
       d.tax_type,
       d.tax_amount,
       d.line_amount,
       d.account_code
FROM   [stg].[xero_invoice_header] AS h
       INNER JOIN
       [stg].[xero_invoice_details] AS d
       ON h.invoice_id = d.invoice_id;