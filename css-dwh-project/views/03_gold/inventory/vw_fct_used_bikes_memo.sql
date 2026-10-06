CREATE
-- OR ALTER
VIEW [marts].[vw_fct_used_bikes_memo] AS
SELECT
        used_bike_id,
        service_order_number,
        web_bike_id,
        memo_date,
        sold_date,
        NULLIF(customer_code, '') as customer_code,
        sold_customer_code,
        salesperson1_key,
        salesperson2_key,
        sold_salesperson_key,
        [description] AS description,
        brand,
        product_key,
        cast(retail_price AS decimal(18, 2)) AS retail_price,
        cast(cost_price AS decimal(18, 2)) AS cost_price,
        cast(sale_price AS decimal(18, 2)) AS sale_price,
        cast(sold_price AS decimal(18, 2)) AS sold_price,
        cast(sold_payment_amount AS decimal(18, 2)) AS sold_payment_amount,
        cast(service_cost_price AS decimal(18, 2)) AS service_cost_price,
        used_bike_status,
        used_bike_category,
        cast(web_status AS char) AS web_status,
        order_channel
    FROM
        [int].[used_bikes_memo]
