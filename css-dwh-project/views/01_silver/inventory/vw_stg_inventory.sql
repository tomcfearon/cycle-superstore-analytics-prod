CREATE
-- OR ALTER
VIEW [stg].[inventory] AS
SELECT
    inv.[stock_key]     AS [product_key], -- source column aliased to domain name at stg boundary
    inv.[quantity_on_hand_t1],
    inv.[quantity_on_hand_t2],
    inv.[quantity_on_hand_cara],
    CAST(inv.[query_datetime] AS DATE) AS query_date
-- Read the inventory snapshot from its dedicated raw schema
FROM [raw_ccdata].[Inventory] AS inv;
