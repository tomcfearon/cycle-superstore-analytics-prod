CREATE VIEW [marts].[vw_fct_xero_bank_transaction_debits]
AS
SELECT bank_transaction_id,
       transaction_date,
       contact_name,
       contact_type,
       account_code,
       line_amount AS amount,
       tax_amount,
       [description],
       currency_code,
       updated_date_utc
FROM   [int].[xero_bank_transactions]
WHERE  transaction_flow = 'Debit';