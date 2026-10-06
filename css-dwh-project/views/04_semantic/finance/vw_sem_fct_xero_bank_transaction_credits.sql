CREATE VIEW -- OR ALTER
[dbo].[18 - Xero Bank Transaction Credits]
AS
SELECT [bank_transaction_id] AS [Bank Transaction ID],
       [transaction_date] AS [Transaction Date],
       [contact_name] AS [Contact Name],
       [contact_type] AS [Contact Type],
       [account_code] AS [Account Code],
       [amount] AS [Amount],
       [tax_amount] AS [Tax Amount],
       [description] AS [Description],
       [currency_code] AS [Currency Code],
       [updated_date_utc] AS [Updated Date UTC]
FROM   [marts].[fct_xero_bank_transaction_credits];