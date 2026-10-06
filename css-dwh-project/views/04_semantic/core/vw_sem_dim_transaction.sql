CREATE
-- OR ALTER
VIEW [dbo].[47 - Transaction] AS
SELECT
    [transaction_key]  AS [Transaction Key],
    [document_number]  AS [Document Number],
    [document_type]    AS [Document Type],
    [internal_note]    AS [Internal Note]
FROM [marts].[dim_transaction];
