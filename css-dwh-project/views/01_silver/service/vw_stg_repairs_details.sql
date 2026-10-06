CREATE VIEW -- OR ALTER
[stg].[repairs_details]
AS
SELECT rd.FaultNo AS fault_no,
       rd.StockCode AS stock_code,
       rd.[Description] AS [description],
       rd.Qty AS quantity,
       rd.CostPrice AS cost_price,
       rd.SellPrice AS sell_price,
       rd.GroupSeqNo AS group_seq_no,
       rd.SiteNo AS site_no,
       rd.StockLocation AS stock_location,
       rd.Credited AS credited,
       rd.CreditNo AS credit_no,
       rd.Broken AS broken,
       rd.Reason AS reason,
       rd.ItemType AS item_type,
       rd.RequestID AS request_id,
       rd.DiscountApprovedBy AS discount_approved_by,
       rd.MultiBuyDiscount AS multi_buy_discount,
       rd.StockPrice AS stock_price,
       rd.TaxCode AS tax_code
FROM   [raw_ccdata].[RepairsDetails] AS rd;