CREATE VIEW -- OR ALTER
[int].[pos_credit_notes_header]
AS
SELECT sh.invoice_no AS credit_number,
       CAST (sh.invoice_date AS DATE) AS credit_date,
       sh.customer_code,
       sh.salesperson AS salesperson_name,
       sh.row_modified_datetime -- passed through from raw_ccdata.SundryHeader for incremental audit
FROM   [stg].[sundry_header] AS sh
WHERE  sh.trans_type = 4
       AND sh.invoice_no IS NOT NULL;