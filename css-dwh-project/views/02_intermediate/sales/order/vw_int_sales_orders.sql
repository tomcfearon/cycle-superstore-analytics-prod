CREATE
-- OR ALTER
VIEW [int].[int_sales_orders] AS
-- Dedupe employees by name to prevent LEFT JOIN fan-out (see vw_int_fact_repair_lines.sql).
WITH deduped_employees
AS     (SELECT employee_key,
               employee_name,
               ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
        FROM   [int].[employees])
SELECT
    'SAL-ORD-' + h.order_number           AS transaction_key, -- prefixed key; replaces order_number as the row identifier
    cast(h.order_datetime AS time(0))     AS order_time,
    h.order_date,
    h.customer_code,
    h.deposit_value,
    h.payment_to_date,
    h.collection_date,
    h.box_number,
    h.order_status,
    h.web_order_id,
    h.is_confirmed,
    h.bike_location,
    d.price,
    d.quantity,
    d.vat_amount,
    CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3')
         THEN d.[description]
         ELSE NULL
    END AS [description], -- null for real product lines; populated only for misc/placeholder keys
    d.line_sequence_number,
    d.quantity_taken,
    d.request_id,
    d.is_pulled,
    d.discount_approver_id AS approver_key,
    isnull(e.employee_key, -1) AS employee_key,
    isnull(c.employee_key, -1) AS collection_employee_key,
    isnull(m.product_key, 'MISC-3') AS product_key,
    CASE
        WHEN (
            d.cost IS NULL
            OR d.cost = 0
        )
        AND d.product_id IN ('MISC', 'SWAP', 'ORDER') THEN ((d.price - d.vat_amount) / 2.0)
        ELSE isnull(d.cost, 0)
    END AS cost,
    (d.unit_price_before_discount * d.quantity) AS price_before_discount
FROM
    [stg].[sales_order_header] AS h
    LEFT JOIN [stg].[sales_order_details] AS d ON h.order_number = d.order_number
    LEFT JOIN deduped_employees AS e ON h.salesperson_name = e.employee_name AND e.rn = 1
    LEFT JOIN [int].[product_code_to_product_key_mapping] AS m ON m.product_id = d.product_id
    LEFT JOIN [int].[sales_order_collections] AS c ON h.order_number = c.order_number
