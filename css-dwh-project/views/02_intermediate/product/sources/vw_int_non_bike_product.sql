CREATE VIEW -- OR ALTER
[int].[non_bike_product]
AS
SELECT s.product_id + '-0' AS product_key,
       s.product_id,
       s.stock_code,
       s.temp_stock_code,
       s.brand,
       s.title,
       s.old_category,
       s.old_subcategory,
       COALESCE (m.new_category, UPPER(LTRIM(RTRIM(ISNULL(CAST (s.old_category AS VARCHAR (100)), ''))))) AS category,
       COALESCE (m.new_subcategory, UPPER(LTRIM(RTRIM(ISNULL(CAST (s.old_subcategory AS VARCHAR (100)), ''))))) AS subcategory,
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
       s.sale_price,
       s.trade_sale_price,
       s.is_active,
       s.is_on_web,
       s.is_discontinued,
       s.size,
       s.model_year,
       CAST (ISNULL(mk.is_distribution, 0) AS BIT) AS is_distribution,
       s.main_sundry_repairs,
       s.row_modified_datetime -- ERP-stamped datetime; used for incremental watermark in dim_product
FROM   [stg].[product] AS s
       LEFT OUTER JOIN
       [stg].[category_map_temp] AS m
       ON UPPER(LTRIM(RTRIM(ISNULL(CAST (s.old_category AS VARCHAR (100)), '')))) = m.old_category
          AND UPPER(LTRIM(RTRIM(ISNULL(CAST (s.old_subcategory AS VARCHAR (100)), '')))) = m.old_subcategory
       LEFT OUTER JOIN
       [stg].[makes] AS mk
       ON LOWER(LTRIM(RTRIM(s.brand))) = LOWER(LTRIM(RTRIM(mk.make)))
WHERE  s.main_sundry_repairs NOT IN ('Main', 'Repairs');