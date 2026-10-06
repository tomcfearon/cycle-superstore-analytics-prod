CREATE
-- OR ALTER
VIEW [int].[product_consolidated_enriched]
AS
    WITH final AS
    (
        SELECT
            f.product_key,
            f.stock_code,
            f.web_product_id,
            f.web_parent_product_id,
            CASE WHEN f.product_key = 'MISC-3' THEN '-' ELSE NULLIF(TRIM(f.raw_brand), '') END AS erp_brand,
            NULLIF(TRIM(COALESCE(NULLIF(TRIM(f.brand_name), ''), NULLIF(TRIM(f.brand), ''))), '') AS brand,
            f.title,
            COALESCE(NULLIF(f.category, ''), 'Miscellaneous') AS category,
            CASE WHEN NULLIF(f.category, '') IS NULL THEN NULL ELSE f.subcategory END AS subcategory,
            f.retail_price,
            f.cost_price,
            f.average_cost_price,
            f.selling_price_1,
            f.selling_price_2,
            f.selling_price_3,
            f.selling_price_4,
            f.selling_price_5,
            f.selling_price_6,
            f.selling_price_7,
            f.sale_price,
            f.trade_sale_price,
            CAST(ISNULL(mk.is_active, 0) AS bit) AS is_active,
            f.is_on_web,
            f.is_discontinued,
            f.web_price,
            f.web_list_price,
            f.extended_warehouse_quantity,
            f.web_is_active,
            f.web_is_list_hidden,
            f.color,
            f.size,
            f.product_options_last_refreshed,
            f.item_groupings_last_refreshed,
            f.web_link,
            f.main_image_link,
            f.additional_image_links,
            f.web_category_id,
            f.product_type,
            f.gpc_path,
            f.web_title,
            f.web_item_group_title,
            f.variant_descriptor,
            f.web_html_details,
            CASE
                WHEN COALESCE(NULLIF(f.brand_name, ''), f.brand) = 'Assos'
                    AND f.title LIKE '% NEW %'
                    THEN CAST(1 AS bit)
                ELSE CAST(0 AS bit)
            END AS is_new,
            f.web_gender,
            f.web_item_material,
            f.web_is_bike_product,
            f.model_year,
            f.is_distribution,
            f.main_sundry_repairs,
            CASE
                WHEN LOWER(COALESCE(COALESCE(f.web_item_group_title, f.web_title), f.title)) LIKE '%winter%' THEN 'Winter'
                WHEN LOWER(COALESCE(COALESCE(f.web_item_group_title, f.web_title), f.title)) LIKE '%summer%' THEN 'Summer'
                WHEN LOWER(COALESCE(COALESCE(f.web_item_group_title, f.web_title), f.title)) LIKE '%spring%'
                    OR LOWER(COALESCE(COALESCE(f.web_item_group_title, f.web_title), f.title)) LIKE '%fall%' THEN 'Spring/Fall'
                ELSE NULL
            END AS stock_type,
            CASE
                WHEN LOWER(f.category) IN ('city / hybrid', 'electric', 'gravel & cyclocross', 'kids', 'mountain', 'road') THEN 'Bikes'
                ELSE 'Sundry'
            END AS bike_sundry,
            CASE
                WHEN LOWER(f.category) = 'city / hybrid' THEN 'City Bikes'
                WHEN LOWER(f.category) = 'electric' THEN 'Electric'
                WHEN LOWER(f.category) = 'gravel & cyclocross' THEN 'Gravel Bikes'
                WHEN LOWER(f.category) = 'kids' THEN 'Kids Bikes'
                WHEN LOWER(f.category) = 'mountain' THEN 'Mountain Bikes'
                WHEN LOWER(f.category) = 'road' THEN 'Road Bikes'
                ELSE 'Sundry'
            END AS bike_category,
            CASE
                WHEN LOWER(f.category) = 'electric' THEN 'Electric'
                WHEN LOWER(f.category) IN ('city / hybrid', 'gravel & cyclocross', 'kids', 'mountain', 'road') THEN 'Manual'
                ELSE 'Sundry'
            END AS electric_manual_sundry,
            CASE
                WHEN LOWER(f.subcategory) IN ('city', 'e-cargo', 'e-city', 'folding / compact') THEN 'City Bikes'
                WHEN LOWER(f.subcategory) IN ('12 inch', '12-26 inch', '14-16 inch', '18-20 inch', '24 inch', '26 inch', '29 inch', 'bmx') THEN 'Kids'
                WHEN LOWER(f.subcategory) IN ('e-mountain full suspension', 'e-mountain hardtail', 'full suspension', 'hardtail') THEN 'Mountain Bikes'
                WHEN LOWER(f.subcategory) IN ('cyclocross bikes', 'e-gravel', 'e-road', 'gravel bikes', 'road bikes', 'time trial / triathlon') THEN 'Road / Gravel'
                WHEN LOWER(f.category) = 'city / hybrid' THEN 'City Bikes'
                WHEN LOWER(f.category) = 'electric' THEN 'City Bikes'
                WHEN LOWER(f.category) = 'gravel & cyclocross' THEN 'Gravel Bikes'
                WHEN LOWER(f.category) = 'kids' THEN 'Kids Bikes'
                WHEN LOWER(f.category) = 'mountain' THEN 'Mountain Bikes'
                WHEN LOWER(f.category) = 'road' THEN 'Road Bikes'
                ELSE 'Sundry'
            END AS main_bike_type,
            f.row_modified_datetime,
            gs.benchmark_price,
            gs.suggested_price,
            gs.google_category
        FROM [int].[product_consolidated_base] AS f
            LEFT JOIN [stg].[makes] AS mk
                ON LOWER(LTRIM(RTRIM(f.raw_brand))) = LOWER(LTRIM(RTRIM(mk.make)))
            LEFT JOIN [int].[product_google_signals] AS gs
                ON gs.product_id_key = CAST(f.web_product_id AS varchar(52))
    ),
    final_with_sundry AS
    (
        SELECT
            f.*,
            CASE
                WHEN LOWER(f.subcategory) IN ('city', 'e-cargo', 'e-city', 'folding / compact') THEN 'City Bikes'
                WHEN LOWER(f.category) = 'kids' AND LOWER(TRIM(f.subcategory)) = 'tubes' THEN 'Bike Components'
                WHEN LOWER(f.subcategory) IN ('12 inch', '12-26 inch', '14-16 inch', '18-20 inch', '24 inch', '26 inch', '29 inch', 'bmx') THEN 'Kids Bikes'
                WHEN LOWER(f.subcategory) IN ('e-mountain full suspension', 'e-mountain hardtail', 'full suspension', 'hardtail') THEN 'Mountain Bikes'
                WHEN LOWER(f.subcategory) IN ('cyclocross bikes', 'e-gravel', 'e-road', 'gravel bikes', 'road bikes', 'time trial / triathlon') THEN 'Road / Gravel'
                WHEN LOWER(f.category) = 'city / hybrid' THEN 'City Bikes'
                WHEN LOWER(f.category) = 'electric' THEN 'City Bikes'
                WHEN LOWER(f.category) = 'gravel & cyclocross' THEN 'Gravel Bikes'
                WHEN LOWER(f.category) = 'kids' AND LOWER(TRIM(f.subcategory)) = 'tubes' THEN 'Bike Components'
                WHEN LOWER(f.category) = 'kids' THEN 'Kids Bikes'
                WHEN LOWER(f.category) = 'mountain' THEN 'Mountain Bikes'
                WHEN LOWER(f.category) = 'road' THEN 'Road / Gravel'
                WHEN f.category IN ('Trousers & Tights', 'Overshoes', 'Socks', 'Bib Shorts',
                                    'Arm & Leg Warmers', 'Shoes', 'Hats, Caps & Buffs', 'Jackets',
                                    'Kids Clothing', 'Shorts', 'Vests', 'Helmets', 'Gloves / Mitts',
                                    'Base Layers', 'Jerseys', 'Body Protection', 'Eyewear') THEN 'Apparel & Gear'
                WHEN f.category IN ('Brakes', 'Wheels', 'Handlebars & Stems', 'Saddles',
                                    'Drivetrain', 'Pedals & Cleats', 'Frames & Suspension',
                                    'Tyres', 'Tubes', 'Chains', 'Seatposts') THEN 'Bike Components'
                WHEN f.category IN ('Bottles & Cages', 'Locks', 'Carriers & Baskets', 'Mudguards',
                                    'Backpacks & Waist Bags', 'Panniers & Saddle Bags',
                                    'Child Seats & Trailers', 'Lights', 'Car Racks') THEN 'Accessories & Storage'
                WHEN f.category IN ('Tools', 'Bike Maintenance', 'Pumps') THEN 'Maintenance & Tools'
                WHEN f.category IN ('Triathlon', 'Energy Food & Drink', 'Training', 'Electronics') THEN 'Training, Tech & Nutrition'
                WHEN f.category IN ('Miscellaneous', 'Parts & Accessories', 'Bike Transport') THEN 'Miscellaneous'
                ELSE 'Other Uncategorized'
            END AS category_type
        FROM final AS f
    )
    SELECT
        f.product_key,
        f.stock_code,
        f.brand,
        f.erp_brand,
        f.title,
        COALESCE(NULLIF(f.web_item_group_title, ''), NULLIF(f.web_title, ''), f.title) AS product_group_title,
        f.category,
        f.subcategory,
        f.retail_price,
        f.cost_price,
        f.average_cost_price,
        f.selling_price_1,
        f.selling_price_2,
        f.selling_price_3,
        f.selling_price_4,
        f.selling_price_5,
        f.selling_price_6,
        f.selling_price_7,
        f.sale_price,
        f.trade_sale_price,
        f.is_active,
        f.is_on_web,
        f.is_discontinued,
        f.web_is_active,
        f.web_is_list_hidden,
        f.color,
        f.size,
        f.product_options_last_refreshed,
        f.item_groupings_last_refreshed,
        f.title AS store_db_title,
        f.web_link,
        f.main_image_link,
        f.additional_image_links,
        f.gpc_path AS web_category_path,
        f.google_category,
        f.web_html_details AS html_details,
        f.web_gender AS gender,
        f.web_item_material AS item_material,
        f.web_product_id,
        f.web_parent_product_id,
        f.web_price,
        f.web_list_price,
        f.extended_warehouse_quantity,
        f.web_is_bike_product,
        f.model_year,
        f.is_new,
        f.stock_type,
        f.bike_sundry,
        f.bike_category,
        f.electric_manual_sundry,
        f.main_bike_type,
        f.category_type,
        CASE
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'tubes' THEN 'Tubes'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'e-city' THEN 'Electric City Bike'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'e-cargo' THEN 'Electric Cargo Bike'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'city' THEN 'City Bike'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'folding / compact' THEN 'Folding / Compact Bike'
            WHEN f.bike_sundry = 'Bikes' AND f.category_type = 'City Bikes' AND NULLIF(TRIM(f.subcategory), '') IS NULL THEN 'City Bike'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = '12 inch' THEN '12 Inch'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = '12-26 inch' THEN '12-26 Inch'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = '14-16 inch' THEN '14-16 Inch'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = '18-20 inch' THEN '18-20 Inch'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = '24 inch' THEN '24 Inch'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = '26 inch' THEN '26 Inch'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = '29 inch' THEN '29 Inch'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'bmx' THEN 'BMX'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'kids' THEN 'Kids (Unclassified)'
            WHEN f.bike_sundry = 'Bikes' AND f.category_type = 'Kids Bikes' AND NULLIF(TRIM(f.subcategory), '') IS NULL THEN 'Kids (Unclassified)'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'e-mountain full suspension' THEN 'E-Full Suspension'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'e-mountain hardtail' THEN 'E-Hardtail'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'e-road' THEN 'Electric Road'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'e-gravel' THEN 'Electric Gravel'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'road bikes' THEN 'Road'
            WHEN f.bike_sundry = 'Bikes' AND LOWER(TRIM(f.subcategory)) = 'gravel bikes' THEN 'Gravel'
            WHEN f.bike_sundry = 'Bikes' AND f.category_type = 'Road / Gravel' AND NULLIF(TRIM(f.subcategory), '') IS NULL THEN 'Road'
            WHEN f.bike_sundry = 'Bikes' THEN COALESCE(NULLIF(TRIM(f.subcategory), ''), f.category_type)
            ELSE COALESCE(NULLIF(TRIM(f.category), ''), f.category_type)
        END AS subcategory_type,
        f.variant_descriptor,
        f.is_distribution,
        f.main_sundry_repairs,
        f.benchmark_price,
        f.suggested_price,
        NULLIF(LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                ISNULL(NULLIF(COALESCE(COALESCE(f.web_item_group_title, f.web_title), f.title), ''), ''), ISNULL(f.brand, ''), ''),
                'full suspension mountain bike', ''),
                'hardtail mountain bike', ''),
                'electric mountain bike', ''),
                'electric road bike', ''),
                'electric city bike', ''),
                'electric cargo bike', ''),
                'mountain bike', ''),
                'road bike', ''),
                'city bike', ''),
                'gravel bike', ''),
                'cyclocross bike', ''),
                'kids bike', ''),
            '  ', ' '), '  ', ' ')
        )), '') AS clean_product_name,
        f.row_modified_datetime
    FROM final_with_sundry AS f;