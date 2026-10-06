CREATE
-- OR ALTER
VIEW [marts].[vw_fct_order_credits] AS
SELECT
    oc.transaction_key,
    oc.credit_date,
    oc.customer_code,
    oc.invoice_salesperson_key AS employee_key,
    oc.salesperson_key AS creditor_key,
    oc.product_key,
    oc.quantity,
    oc.price,
    oc.vat_amount,
    oc.cost,
    oc.price_before_discount,
    oc.approver_key,
    oc.credit_date AS order_date,
    cast(NULL AS time(0)) AS order_time,
    cast(0 AS bit) AS is_dispatched,
    oc.invoice_connection_number,
    oc.web_order_id,
    ISNULL(oc.line_sequence_number, 0) AS line_sequence_number, -- NULL would never match itself in the loader's MERGE, causing duplicate inserts
    oc.[description] AS [description],
    oc.row_modified_datetime, -- ERP-stamped datetime from raw_ccdata.InvoiceHeader
    CAST(CASE WHEN oc.web_order_id IS NOT NULL THEN 'Web' ELSE 'In-Store' END AS varchar(50)) AS order_channel,
    oc.collection_employee_key
FROM
    [int].[int_order_credits] AS oc
