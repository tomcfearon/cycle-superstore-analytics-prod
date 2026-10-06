CREATE VIEW -- OR ALTER
[stg].[xero_bank_transaction_details]
AS
WITH   deduped
AS     (SELECT bt.BankTransactionID,
               bt.LineItems,
               ROW_NUMBER() OVER (PARTITION BY bt.BankTransactionID ORDER BY dbo.fn_ParseXeroEpochDate(bt.UpdatedDateUTC) DESC) AS rn
        FROM   raw_xero.BankTransactions AS bt)
SELECT bt.BankTransactionID AS bank_transaction_id,
       li.[Description] AS [description],
       CAST (li.Quantity AS DECIMAL (18, 4)) AS quantity,
       CAST (li.UnitAmount AS DECIMAL (18, 4)) AS unit_amount,
       li.TaxType AS tax_type,
       CAST (li.TaxAmount AS DECIMAL (18, 2)) AS tax_amount,
       CAST (li.LineAmount AS DECIMAL (18, 2)) AS line_amount,
       li.AccountCode AS account_code
FROM   deduped AS bt CROSS APPLY OPENJSON (bt.LineItems) WITH ([Description] NVARCHAR (MAX) '$.Description', Quantity DECIMAL (18, 4) '$.Quantity', UnitAmount DECIMAL (18, 4) '$.UnitAmount', TaxType VARCHAR (50) '$.TaxType', TaxAmount DECIMAL (18, 2) '$.TaxAmount', LineAmount DECIMAL (18, 2) '$.LineAmount', AccountCode VARCHAR (50) '$.AccountCode') AS li
WHERE  bt.rn = 1;