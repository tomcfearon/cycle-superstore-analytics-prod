CREATE
-- OR ALTER
VIEW [marts].[vw_fct_till_invoices] AS
SELECT
    pi.transaction_key,
    pi.receipt_date AS invoice_date,
    pi.customer_code,
    pi.salesperson_key AS employee_key,
    cast(NULL AS int) AS creditor_key,
    pi.product_key,
    pi.quantity,
    pi.price,
    pi.vat_amount,
    pi.cost,
    pi.price_before_discount,
    cast(NULL AS int) AS approver_key,
    pi.receipt_date AS order_date,
    cast(NULL AS time(0)) AS order_time,
    cast(0 AS bit) AS is_dispatched,
    cast(NULL AS varchar(50)) AS invoice_connection_number,
    ISNULL(pi.line_sequence_number, 0) AS line_sequence_number, -- NULL would never match itself in the loader's MERGE, causing duplicate inserts
    pi.[description] AS description,
    cast(pi.receipt_date AS datetime) AS last_modified_datetime,
    cast('In-Store' AS varchar(50)) AS order_channel,
    pi.is_from_credit_note
FROM
    [int].[int_pos_invoices] AS pi
