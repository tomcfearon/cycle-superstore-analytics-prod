CREATE VIEW -- OR ALTER
[int].[bike_product]
AS
SELECT s.stock_code,
       s.temp_stock_code,
       s.brand,
       s.old_category,
       s.old_subcategory,
       s.retail_price,
       s.cost_price,
       s.average_cost_price,
       s.selling_price_1,
       s.selling_price_2,
       s.selling_price_3,
       s.selling_price_4,
       s.selling_price_5,
       s.selling_price_6,
       s.selling_price_7,
       s.product_key,
       s.model_year,
       s.item_type,
       s.title,
       s.sale_price,
       s.trade_sale_price,
       s.is_active,
       s.is_on_web,
       s.is_discontinued,
       s.colour,
       s.trade_price,
       s.supplier_code,
       s.min_stock_level,
       s.part_no,
       s.tax_code,
       s.analysis_dept,
       s.allow_discount,
       s.site_no,
       s.ticket_sku,
       s.size,
       s.commodity_code,
       s.country_of_origin,
       s.weight,
       s.row_modified_datetime,
       COALESCE (m.new_category, UPPER(LTRIM(RTRIM(ISNULL(CAST (s.old_category AS VARCHAR (100)), ''))))) AS category,
       COALESCE (m.new_subcategory, UPPER(LTRIM(RTRIM(ISNULL(CAST (s.old_subcategory AS VARCHAR (100)), ''))))) AS subcategory,
       CAST (ISNULL(mk.is_distribution, 0) AS BIT) AS is_distribution
FROM   [stg].[bike_product] AS s
       LEFT OUTER JOIN
       [stg].[category_map_temp] AS m
       ON UPPER(LTRIM(RTRIM(ISNULL(CAST (s.old_category AS VARCHAR (100)), '')))) = m.old_category
          AND UPPER(LTRIM(RTRIM(ISNULL(CAST (s.old_subcategory AS VARCHAR (100)), '')))) = m.old_subcategory
       LEFT OUTER JOIN
       [stg].[makes] AS mk
       ON LOWER(LTRIM(RTRIM(s.brand))) = LOWER(LTRIM(RTRIM(mk.make)));