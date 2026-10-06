CREATE --erp stock table part two (bike details)
-- OR ALTER
VIEW [stg].[bike_product] AS
SELECT
    p.ModelNo AS stock_code,
    UPPER(LTRIM(RTRIM(p.ModelNo))) AS temp_stock_code,
    p.Make AS brand,
    p.GroupId AS old_category,
    p.GroupId2 AS old_subcategory,
    p.RetailPrice AS retail_price,
    p.CostPrice AS cost_price,
    p.AveCostPrice AS average_cost_price,
    p.SellingPrice1 AS selling_price_1,
    p.SellingPrice2 AS selling_price_2,
    p.SellingPrice3 AS selling_price_3,
    p.SellingPrice4 AS selling_price_4,
    p.SellingPrice5 AS selling_price_5,
    p.SellingPrice6 AS selling_price_6,
    p.SellingPrice7 AS selling_price_7,
    p.ModelNo + '-1' AS product_key,
    p.ModelYear AS model_year,
    p.ItemType AS item_type,
    LTRIM(RTRIM(p.StockDesc)) AS title,
    CASE
        WHEN p.SalePrice IS NULL
        OR p.SaleStartDate IS NULL
        OR p.SaleEndDate IS NULL THEN NULL
        WHEN CAST(GETDATE() AS date) BETWEEN CAST(p.SaleStartDate AS date)
        AND CAST(p.SaleEndDate AS date) THEN p.SalePrice
    END AS sale_price,
    CASE
        WHEN p.TradeSalePrice IS NULL
        OR p.TradeSaleStartDate IS NULL
        OR p.TradeSaleEndDate IS NULL THEN NULL
        WHEN CAST(GETDATE() AS date) BETWEEN CAST(p.TradeSaleStartDate AS date)
        AND CAST(p.TradeSaleEndDate AS date) THEN p.TradeSalePrice
    END AS trade_sale_price,
    CASE
        WHEN p.ItemType = 0 THEN 1
        WHEN p.ItemType = 26 THEN 0
        ELSE NULL
    END AS is_active,
    CASE
        WHEN p.Web = 'web' THEN 1
        ELSE 0
    END AS is_on_web,
    CASE
        WHEN p.[Status] = '*DSC' THEN 1
        ELSE 0
    END AS is_discontinued,
    p.Colour AS colour,
    p.TradePrice AS trade_price,
    p.SupplierCode AS supplier_code,
    p.MinStockLevel AS min_stock_level,
    p.PartNo AS part_no,
    p.TaxCode AS tax_code,
    p.AnalysisDept AS analysis_dept,
    p.AllowDiscount AS allow_discount,
    p.SiteNo AS site_no,
    p.TicketSKU AS ticket_sku,
    NULLIF(TRIM(p.Size), '') AS size, -- normalise blank ERP sizes to NULL
    p.CommodityCode AS commodity_code,
    p.CountryOfOrigin AS country_of_origin,
    p.Weight AS weight,
    ISNULL(p.row_modified_datetime, CAST('1900-01-01' AS datetime2(0))) AS row_modified_datetime -- NULL-guarded: pre-ADF rows default to sentinel so incremental watermark comparisons are always safe
FROM
    [raw_ccdata].[Products] AS p
