CREATE -- web categories
-- OR ALTER
VIEW [stg].[categories_products] AS
SELECT
    cast([idProduct] AS varchar(100)) AS item_group_id, -- Fix: was CAST AS int, causing INT/VARCHAR type mismatch in vw_int_web_product_integrated JOIN
    cast([idCategory] AS int) AS old_category_id
FROM
    [raw_css2].[categories_products]
