CREATE VIEW -- OR ALTER
[int].[xero_bank_transactions]
AS
SELECT h.bank_transaction_id,
       CASE WHEN h.[type] LIKE 'SPEND%' THEN 'Debit' WHEN h.[type] LIKE 'RECEIVE%' THEN 'Credit' ELSE NULL END AS transaction_flow, -- SPEND* = money out, RECEIVE* = money in
       CASE WHEN h.[type] LIKE 'SPEND%' THEN 'Supplier' WHEN h.[type] LIKE 'RECEIVE%' THEN 'Customer' ELSE NULL END AS contact_type, -- inferred from transaction direction, not a separate Contacts pull
       h.[type],
       h.[status],
       h.transaction_date,
       h.[reference],
       h.currency_code,
       h.currency_rate,
       h.sub_total,
       h.total_tax,
       h.total,
       h.updated_date_utc,
       h.contact_name,
       h.bank_account_code,
       h.bank_account_name,
       d.[description],
       d.quantity,
       d.unit_amount,
       d.tax_type,
       d.tax_amount,
       d.line_amount,
       d.account_code
FROM   [stg].[xero_bank_transaction_header] AS h
       INNER JOIN
       [stg].[xero_bank_transaction_details] AS d
       ON h.bank_transaction_id = d.bank_transaction_id;
