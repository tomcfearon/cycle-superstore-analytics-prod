CREATE --web extra product details (color, size)
-- OR ALTER
VIEW [stg].[web_product_options] AS
SELECT
    CAST([idProduct] AS varchar(20)) AS web_product_id, -- Keep mixed-format web IDs such as v-gift-20 as text.
    [color] AS product_option_color,
    [size] AS product_option_size,
    [LastRefreshed] AS product_options_last_refreshed
FROM
raw_css2.ProductOptions_T;
