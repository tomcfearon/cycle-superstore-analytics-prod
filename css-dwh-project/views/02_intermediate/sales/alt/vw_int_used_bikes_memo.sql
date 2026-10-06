CREATE
-- OR ALTER
VIEW [int].[used_bikes_memo] AS
SELECT
    ub.used_bike_id,
    ub.service_order_number,
    ub.web_bike_id,
    ub.memo_date,
    ub.sold_date,
    ub.customer_code,
    ub.sold_customer_code,
    ISNULL(NULLIF(ub.salesperson1_key, 0), -1) AS salesperson1_key,
    ISNULL(NULLIF(ub.salesperson2_key, 0), -1) AS salesperson2_key,
    ISNULL(NULLIF(ub.sold_salesperson_key, 0), -1) AS sold_salesperson_key,
    ub.[description],
    ub.brand,
    ISNULL(m.product_key, 'MISC-3') AS product_key,
    ub.retail_price,
    ub.cost_price,
    ub.sale_price,
    ub.sold_price,
    ub.sold_payment_amount,
    ub.service_cost_price,
    ub.used_bike_status,
    ub.used_bike_category,
    ub.web_status,
    CAST('In-Store' AS varchar(50)) AS order_channel
FROM
    [stg].[used_bike_memo] AS ub
    LEFT JOIN (SELECT DISTINCT product_key FROM [int].[product_code_to_product_key_mapping]) AS m
        ON m.product_key = NULLIF(RTRIM(LTRIM(ub.model_no)), '') + '-1';