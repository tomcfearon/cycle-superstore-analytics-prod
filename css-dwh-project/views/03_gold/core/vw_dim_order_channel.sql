CREATE VIEW [marts].[vw_dim_order_channel]
AS
SELECT 
    CAST('Web' AS VARCHAR(20))           AS [order_channel],
    CAST('Web Order' AS VARCHAR(50))     AS [order_channel_label]
UNION ALL
SELECT 
    CAST('In-Store' AS VARCHAR(20))      AS [order_channel],
    CAST('In-Store' AS VARCHAR(50))      AS [order_channel_label];
