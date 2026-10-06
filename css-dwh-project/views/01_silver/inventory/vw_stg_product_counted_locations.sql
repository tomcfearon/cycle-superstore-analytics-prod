-- stock on hand by location (used for stock counts)
CREATE
-- OR ALTER
VIEW [stg].[product_counted_locations] AS
SELECT
    sc.StockCode AS product_id,
    sc.StockLocation AS location_name,
    sc.QtyOnHand AS quantity_on_hand,
    sc.QtyOnOrder AS quantity_on_order,
    sc.QtyReserved AS quantity_reserved,
    sc.MinStockLevel AS min_stock_level,
    sc.DateSold AS date_sold,
    sc.MaxStockLevel AS max_stock_level,
    sc.QtyFaulty AS quantity_faulty,
    sc.DateCounted AS date_counted,
    sc.BinNo AS bin_no
FROM
    [raw_ccdata].[StockCountedLocations] AS sc
WHERE
    sc.StockCode NOT LIKE '%-BOX'