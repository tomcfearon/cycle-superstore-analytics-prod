CREATE VIEW -- OR ALTER
[int].[pos_invoice_notes_header]
AS
SELECT sh.invoice_no AS invoice_number,
       CAST (sh.invoice_date AS DATE) AS invoice_date,
       sh.salesperson AS salesperson_name,
       sh.customer_code,
       sh.row_modified_datetime -- passed through from raw_ccdata.SundryHeader for incremental audit
FROM   [stg].[sundry_header] AS sh
WHERE  sh.trans_type = 3
       AND sh.invoice_no IS NOT NULL;