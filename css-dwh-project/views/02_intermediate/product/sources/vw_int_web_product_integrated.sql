CREATE -- gets table conversion
-- OR ALTER
VIEW [int].[vw_web_product_integrated] AS
    WITH
        web_bike_new_ids
        AS
        (
            SELECT v.category_id
            FROM (
        VALUES
                    (1),
                    (2),
                    (3),
                    (4),
                    (5),
                    (6),
                    (7),
                    (8),
                    (9),
                    (10),
                    (11),
                    (12),
                    (13),
                    (14),
                    (15),
                    (16),
                    (17),
                    (18),
                    (19),
                    (20),
                    (21),
                    (22),
                    (23),
                    (24),
                    (25),
                    (26),
                    (27),
                    (28),
                    (175),
                    (176),
                    (177) -- incl. frames
        ) v(category_id)
        ),
        web_bike_old_ids
        AS
        (
            SELECT v.category_id
            FROM (
        VALUES
                    (31),
                    (32),
                    (35),
                    (36),
                    (37),
                    (38),
                    (39),
                    (48),
                    (49),
                    (232),
                    (233),
                    (265),
                    (272),
                    (315),
                    (316),
                    (317),
                    (319),
                    (321)
        ) v(category_id)
        ),
        raw
        AS
        (
            SELECT ws.web_product_id,
                ws.web_parent_product_id,
                ws.web_title,
                ws.web_price,
                ws.web_list_price,
                ws.web_supplier_qty AS extended_warehouse_quantity,
                ws.web_is_active,
                ws.web_is_list_hidden,
                po.product_option_color AS color,
                NULLIF(TRIM(po.product_option_size), '') AS [size], -- normalise blank web sizes to NULL
                po.product_options_last_refreshed,
                ig.item_grouping_brand_name AS brand_name,
                ig.item_grouping_link AS web_link,
                ig.item_grouping_image_link AS main_image_link,
                ig.item_grouping_image_links AS additional_image_links,
                ig.item_grouping_category_id AS web_category_id,
                ig.item_grouping_product_type AS product_type,
                ig.item_grouping_gpc_path AS gpc_path,
                ig.item_grouping_details AS web_html_details,
                ig.item_grouping_gender_name AS web_gender,
                ig.item_grouping_material_name AS web_item_material,
                ig.item_groupings_last_refreshed,
                cp.old_category_id,
                UPPER(LTRIM(RTRIM(ws.stock_code))) AS stock_code_key
            FROM [stg].[web_product] AS ws
                LEFT JOIN [stg].[web_product_options] AS po ON ws.web_product_id = po.web_product_id
                LEFT JOIN [stg].[web_item_groupings] AS ig ON ws.web_parent_product_id = ig.item_group_id
                LEFT JOIN [stg].[categories_products] AS cp ON cp.item_group_id = ig.item_group_id
            WHERE ws.stock_code IS NOT NULL
        ),
        labeled
        AS
        (
            SELECT r.*,
                CASE
            WHEN r.web_category_id IN (
                    SELECT category_id
                    FROM web_bike_new_ids
                    )
                    OR r.old_category_id IN (
                    SELECT category_id
                    FROM web_bike_old_ids
                    )
                THEN CAST(1 AS BIT)
            ELSE CAST(0 AS BIT)
            END AS is_bike_product
            FROM raw AS r
        ),
        dedup
        AS
        (
            SELECT *
            FROM (
        SELECT r.*,
                    ROW_NUMBER() OVER (
                PARTITION BY r.is_bike_product,
                r.stock_code_key ORDER BY r.web_product_id DESC
                ) AS rn
                FROM labeled AS r
        ) AS x
            WHERE x.rn = 1
        )
    SELECT d.is_bike_product,
        d.stock_code_key AS stock_code,
        d.web_product_id,
        d.web_parent_product_id,
        d.web_title,
        d.web_price,
        d.web_list_price,
        d.extended_warehouse_quantity,
        d.web_is_active,
        d.web_is_list_hidden,
        d.color,
        d.[size],
        d.product_options_last_refreshed,
        d.brand_name,
        d.web_link,
        d.main_image_link,
        d.additional_image_links,
        d.web_category_id,
        d.product_type,
        d.gpc_path,
        d.web_html_details,
        d.web_gender,
        d.web_item_material,
        d.item_groupings_last_refreshed,
        CASE
        WHEN CHARINDEX(' (', d.web_title) > 0
            THEN LEFT(d.web_title, CHARINDEX(' (', d.web_title) - 1)
        ELSE d.web_title
        END AS web_item_group_title,
        -- variant_descriptor: colour/size suffix stored inside the parens of web_title
        -- e.g. "Trek Domane SL 5 (Red/Black - M)" -> "Red/Black - M". NULL if no parens.
        CASE
        WHEN CHARINDEX(' (', d.web_title) > 0
             AND RIGHT(RTRIM(d.web_title), 1) = ')'
        THEN NULLIF(
                 TRIM(
                     SUBSTRING(
                         d.web_title,
                         CHARINDEX(' (', d.web_title) + 2,
                         LEN(d.web_title) - CHARINDEX(' (', d.web_title) - 2
                     )
                 ),
             '')
        ELSE NULL
        END AS variant_descriptor
    FROM dedup AS d;
    -- WHERE d.size IS NOT NULL
-- SELECT TOP 100 *
-- FROM [marts].[dim_product]
-- WHERE variant_descriptor IS NOT NULL
