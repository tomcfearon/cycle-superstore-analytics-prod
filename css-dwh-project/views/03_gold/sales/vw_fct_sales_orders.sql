CREATE
-- OR ALTER
VIEW [marts].[vw_fct_sales_orders] AS
SELECT
    transaction_key,
    order_time,
    order_date,
    employee_key,
    customer_code,
    deposit_value,
    payment_to_date,
    collection_date,
    box_number,
    order_status,
    web_order_id,
    cast(is_confirmed AS bit) AS is_confirmed,
    bike_location,
    product_key,
    price,
    quantity,
    vat_amount,
    cost,
    [description] AS description,
    line_sequence_number,
    quantity_taken,
    price_before_discount,
    request_id,
    is_pulled,
    approver_key,
    CAST(CASE WHEN web_order_id IS NOT NULL THEN 'Web' ELSE 'In-Store' END AS varchar(50)) AS order_channel,
    collection_employee_key
FROM
    [int].[int_sales_orders]
