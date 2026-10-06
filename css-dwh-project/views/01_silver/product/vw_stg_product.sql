CREATE
-- erp stock table part one (used products)
-- OR ALTER
VIEW [stg].[product]
AS
SELECT s.StockCode AS product_id,
       -- Renamed here
       s.ModelNo AS stock_code,
       -- Renamed here
       UPPER(LTRIM(RTRIM(s.ModelNo))) AS temp_stock_code,
       s.MakeID AS brand,
       LTRIM(RTRIM(s.StockDesc)) AS title,
       s.GroupId AS old_category,
       s.GroupId2 AS old_subcategory,
       s.RetailPrice AS retail_price,
       s.AveCostPrice AS average_cost_price,
       s.SellingPrice1 AS selling_price_1,
       s.SellingPrice2 AS selling_price_2,
       s.SellingPrice3 AS selling_price_3,
       s.SellingPrice4 AS selling_price_4,
       s.SellingPrice5 AS selling_price_5,
       s.SellingPrice6 AS selling_price_6,
       s.SellingPrice7 AS selling_price_7,
       CASE WHEN s.SalePrice IS NULL
                 OR s.SaleStartDate IS NULL
                 OR s.SaleEndDate IS NULL THEN NULL WHEN CAST (GETDATE() AS DATE) BETWEEN CAST (s.SaleStartDate AS DATE) AND CAST (s.SaleEndDate AS DATE) THEN s.SalePrice END AS sale_price,
       CASE WHEN s.TradeSalePrice IS NULL
                 OR s.TradeSaleStartDate IS NULL
                 OR s.TradeSaleEndDate IS NULL THEN NULL WHEN CAST (GETDATE() AS DATE) BETWEEN CAST (s.TradeSaleStartDate AS DATE) AND CAST (s.TradeSaleEndDate AS DATE) THEN s.TradeSalePrice END AS trade_sale_price,
       CASE WHEN s.ItemType IN (26, 16) THEN 0 ELSE 1 END AS is_active,
       CASE WHEN s.Web = 'web' THEN 1 ELSE 0 END AS is_on_web,
       CASE WHEN s.[Status] = '*DSC' THEN 1 ELSE 0 END AS is_discontinued,
       s.StockLocation AS stock_location,
       s.ItemType AS item_type,
       s.ModelYear AS model_year,
       s.PartNo AS part_no,
       s.Colour AS colour,
       s.PriceBand AS price_band,
       s.CostPrice AS cost_price,
       s.TradePrice AS trade_price,
       s.ManufactureGuarantee AS manufacture_guarantee,
       s.SupplierCode AS supplier_code,
       s.DueIn AS due_in,
       CAST (s.DatePurchased AS DATE) AS date_purchased,
       s.DateSold AS date_sold,
       s.DespatchNo AS despatch_no,
       s.PurchaseOrderNo AS purchase_order_no,
       s.CustomerCode AS customer_code,
       s.OrderRef AS order_ref,
       s.Reserved AS reserved,
       s.InvoiceLink AS invoice_link,
       s.ReservedType AS reserved_type,
       s.AnalysisDept AS analysis_dept,
       s.TaxCode AS tax_code,
       s.NoLabelFlag AS no_label_flag,
       s.AllowDiscount AS allow_discount,
       s.SiteNo AS site_no,
       s.TicketSKU AS ticket_sku,
       s.season AS season,
       s.[catalogue cost price gbp] AS catalogue_cost_price_gbp,
       s.[catalogue retail price gbp] AS catalogue_retail_price_gbp,
       s.[Date of Clearance] AS date_of_clearance,
       NULLIF (TRIM(s.Size), '') AS size, -- normalise blank ERP sizes to NULL
       s.CommodityCode AS commodity_code,
       s.CountryOfOrigin AS country_of_origin,
       s.Weight AS weight,
       s.BoxQty AS box_qty,
       s.BoxItemStockCode AS box_item_stock_code,
       s.WriteDownValue AS write_down_value,
       CASE WHEN s.ItemType = 0 THEN 'Main' WHEN s.ItemType = 1 THEN 'Sundry' WHEN s.ItemType = 4 THEN 'Main' WHEN s.ItemType = 7 THEN 'Repairs' WHEN s.ItemType = 10 THEN 'Main' WHEN s.ItemType = 15 THEN 'Main' WHEN s.ItemType = 16 THEN 'Sundry' WHEN s.ItemType = 25 THEN 'Sundry' WHEN s.ItemType = 26 THEN 'Sundry' WHEN s.ItemType = 99 THEN 'Main' ELSE NULL END AS main_sundry_repairs, --some old stock is main but npd
       ISNULL(s.row_modified_datetime, CAST ('1900-01-01' AS DATETIME2 (0))) AS row_modified_datetime -- NULL-guarded: pre-ADF rows default to sentinel so incremental watermark comparisons are always safe
FROM   [raw_ccdata].[Stock] AS s;