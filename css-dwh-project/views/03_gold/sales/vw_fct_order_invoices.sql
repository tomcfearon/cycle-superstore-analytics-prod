CREATE
-- OR ALTER
VIEW [marts].[vw_fct_order_invoices] AS
SELECT
    oi.transaction_key,
    oi.invoice_date,
    oi.customer_code,
    oi.salesperson_key AS employee_key,
    cast(NULL AS int) AS creditor_key,
    oi.product_key,
    oi.quantity,
    oi.price,
    oi.vat_amount,
    oi.cost,
    oi.price_before_discount,
    oi.approver_key,
    oi.order_date,
    oi.order_time,
    cast(NULL AS varchar(50)) AS invoice_connection_number,
    oi.web_order_id,
    ISNULL(oi.line_sequence_number, 0) AS line_sequence_number, -- NULL would never match itself in the loader's MERGE, causing duplicate inserts
    oi.[description] AS description,
    oi.row_modified_datetime, -- ERP-stamped datetime from raw_ccdata.InvoiceHeader
    isnull(oi.is_dispatched, 0) AS is_dispatched,
    CAST(CASE WHEN oi.customer_code = '1/91962' THEN 1 ELSE 0 END AS bit) AS is_used_bike_invoice,
    CAST(CASE WHEN oi.web_order_id IS NOT NULL THEN 'Web' ELSE 'In-Store' END AS varchar(50)) AS order_channel,
    oi.collection_employee_key,
    isnull(oi.is_credited, 0) AS is_credited
FROM
    [int].[int_order_invoices] AS oi


-- SELECT TOP 100 * FROM [marts].[vw_fct_order_invoices] ORDER BY NEWID();
