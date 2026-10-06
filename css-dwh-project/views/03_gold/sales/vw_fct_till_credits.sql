CREATE
-- OR ALTER
VIEW [marts].[vw_fct_till_credits] AS
SELECT
    pc.transaction_key,
    pc.receipt_date AS credit_date,
    pc.customer_code,
    pc.salesperson_key AS employee_key,
    cast(NULL AS int) AS creditor_key,
    pc.product_key,
    pc.quantity,
    pc.price,
    pc.vat_amount,
    pc.cost,
    pc.price_before_discount,
    cast(NULL AS int) AS approver_key,
    pc.receipt_date AS order_date,
    cast(NULL AS time(0)) AS order_time,
    cast(0 AS bit) AS is_dispatched,
    cast(NULL AS varchar(50)) AS invoice_connection_number,
    ISNULL(pc.line_sequence_number, 0) AS line_sequence_number, -- NULL would never match itself in the loader's MERGE, causing duplicate inserts
    pc.[description] AS description,
    cast(pc.receipt_date AS datetime) AS last_modified_datetime,
    cast('In-Store' AS varchar(50)) AS order_channel,
    pc.is_from_invoice_note
FROM
    [int].[int_pos_credits] AS pc
