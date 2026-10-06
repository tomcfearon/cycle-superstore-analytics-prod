CREATE
-- OR ALTER
VIEW [marts].[vw_fct_service_credits] AS
SELECT
    transaction_key,
    credit_number, -- raw varchar key; used by incremental loader for predicate pushdown into InvoiceHeader
    credit_date,
    credit_time,
    order_date,
    customer_code,
    salesperson_employee_key,
    engineer_key,
    creditor_key,
    approver_key,
    invoice_connection_number,
    order_number,
    web_order_id,
    row_modified_datetime, -- ERP-stamped datetime from raw_ccdata.InvoiceHeader (via order_credit_header)
    product_key,
    [description] AS description,
    line_sequence_number,
    quantity,
    price_before_discount,
    price,
    vat_amount,
    cost,
    CAST(CASE WHEN web_order_id IS NOT NULL THEN 'Web' ELSE 'In-Store' END AS varchar(50)) AS order_channel,
    service_type_key -- integer FK assigned upstream in int.base_repair_headers
FROM
    [int].[int_service_credits]
