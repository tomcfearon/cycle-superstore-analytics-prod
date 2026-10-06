GO
CREATE
-- OR ALTER
VIEW [stg].[purchase_order_details] AS
SELECT p.OrderNo AS order_no,
    p.SeqNo AS line_no,
    p.ItemType AS item_type,
    --main is 0,4,6,8,9,12,15
    p.ModelNo AS stock_code,
    --- not sku
    p.Make AS brand,
    p.Description AS description,
    NULLIF(p.Colour, '') AS colour,
    p.PartNo AS part_no,
    --relevance?
    p.StockLocation AS stock_location,
    p.Qty AS qty,
    p.QtyReceived AS qty_received,
    p.Cost AS cost,
    p.RetailPrice AS retail_price,
    p.TradePrice AS trade_price,
    NULLIF(p.SpecialPrice, 0) AS special_price,
    p.BookedDate AS booked_date,
    p.SiteNo AS site_no,
    --useless
    CASE
        WHEN p.ItemType IN (0, 4, 6, 8, 9, 12, 15) THEN 'main'
        ELSE 'sundry'
    END AS item_category
FROM [raw_ccdata].PurchaseOrderDetails AS p;


-- SELECT TOP 100 * FROM [stg].[purchase_order_details]
-- WHERE order_no = '1/15411'
