CREATE
-- OR ALTER
VIEW [int].[order_invoice_header] AS
SELECT
    ih.invoice_no AS invoice_number,
    ih.customer_code,
    ih.invoice_date AS invoice_datetime,
    cast(ih.invoice_date AS date) AS invoice_date,
    ih.salesperson AS salesperson_name,
    ih.order_date AS order_datetime,
    cast(ih.order_date AS date) AS order_date,
    ih.dispatch_details AS is_dispatched,
    ih.web_order_id,
    nullif(ih.order_no, '') AS order_number,
    nullif(trim(ih.in_store_memo), '') AS internal_note,
    isnull(c.employee_key, -1) AS collection_employee_key,
    ih.row_modified_datetime -- passed through from raw_ccdata.InvoiceHeader for incremental audit
FROM
    [stg].[invoice_header] AS ih
    LEFT JOIN [int].[order_invoice_collections] AS c ON ih.invoice_no = c.invoice_number
WHERE
    ih.trans_type = 1; -- Match the ERP salesperson report, which reads only trans_type 1 sales invoices.
