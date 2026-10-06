CREATE
-- OR ALTER
VIEW [dbo].[10 - Inventory] AS
SELECT
    [product_key]             AS [Product Key],
    [quantity_on_hand_t1]     AS [Quantity On Hand T1],
    [quantity_on_hand_cara]   AS [Quantity On Hand Cara],
    [query_date]              AS [Query Date]
FROM [stg].[inventory]
