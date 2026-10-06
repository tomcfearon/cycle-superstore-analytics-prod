CREATE
-- OR ALTER
VIEW [int].[order_credit_header] AS
SELECT
    ih.invoice_no AS credit_number,
    ih.customer_code,
    ih.invoice_date AS credit_datetime,
    cast(ih.invoice_date AS date) AS credit_date,
    ih.salesperson AS salesperson_name,
    nullif(ih.refund_no, '') AS invoice_connection_number,
    nullif(ih.order_no, '') AS order_number,
    nullif(trim(ih.in_store_memo), '') AS internal_note,
    isnull(inv.employee_key, -1) AS collection_employee_key,
    ih.row_modified_datetime -- passed through from raw_ccdata.InvoiceHeader for incremental audit
FROM
    [stg].[invoice_header] AS ih
    LEFT JOIN [int].[order_invoice_collections] AS inv ON nullif(ih.refund_no, '') = inv.invoice_number
WHERE
    ih.trans_type = 2; -- Match the ERP salesperson credit branch, which only reads invoice credits from trans_type 2.
