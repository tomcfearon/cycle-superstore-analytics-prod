CREATE
-- OR ALTER
VIEW [marts].[vw_fct_purchase_orders] AS
SELECT product_key,
    order_number,
    order_date,
    due_in_date,
    goods_in_datetime,
    supplier_code,
    purchase_order_employee_key,
    goods_in_employee_key,
    line_number,
    item_type,
    stock_location,
    quantity,
    quantity_received,
    cost,
    retail_price,
    trade_price
FROM [int].[purchase_orders]