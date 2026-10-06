CREATE --web product groupings table parent level
-- OR ALTER
VIEW [stg].[web_item_groupings] AS
SELECT
    CAST([item_group_id] AS VARCHAR(100))  AS [item_group_id],
    [link] AS item_grouping_link,
    [image_link] AS item_grouping_image_link,
    [image_links] AS item_grouping_image_links,
    [BrandName] AS item_grouping_brand_name,
    [idCategory] AS item_grouping_category_id,
    [product_type] AS item_grouping_product_type,
    [gpc_path] AS item_grouping_gpc_path,
    [details] AS item_grouping_details,
    [gender_name] AS item_grouping_gender_name,
    [material_name] AS item_grouping_material_name,
    [LastRefreshed] AS item_groupings_last_refreshed
FROM
    [raw_css2].[ItemGroupings_T]
