CREATE VIEW -- OR ALTER
[marts].[vw_dim_transaction]
AS
SELECT transaction_key,
       document_number,
       document_type,
       internal_note,
       row_modified_datetime -- NULL for Sales Orders (no source watermark); loader treats NULL as always-include
FROM   [int].[int_dim_transaction];