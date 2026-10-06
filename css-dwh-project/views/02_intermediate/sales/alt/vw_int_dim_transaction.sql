CREATE VIEW -- OR ALTER
[int].[int_dim_transaction]
AS
-- Builds a single header-level document registry across all transaction types.
-- One row per unique document. transaction_key = type prefix + '-' + document number.
-- This feeds dim_transaction and allows Power BI to slice any fact by document ID.
-- Order Invoices
SELECT 'ORD-INV-' + h.invoice_number AS transaction_key,
       h.invoice_number AS document_number,
       CAST ('Order Invoice' AS VARCHAR (50)) AS document_type,
       h.internal_note,
       h.row_modified_datetime
FROM   [int].[order_invoice_header] AS h
UNION ALL
-- Order Credits (credits against order invoices, not service repairs)
SELECT 'ORD-CRD-' + ch.credit_number AS transaction_key,
       ch.credit_number AS document_number,
       CAST ('Order Credit' AS VARCHAR (50)) AS document_type,
       ch.internal_note,
       ch.row_modified_datetime
FROM   [int].[order_credit_header] AS ch
       LEFT OUTER JOIN
       [int].[base_repair_headers] AS rh
       ON ch.invoice_connection_number = rh.invoice_number
WHERE  rh.invoice_number IS NULL -- no matching repair header; classify as order credit
UNION ALL
-- Service Credits (credits against service/repair invoices)
SELECT 'SVC-CRD-' + ch.credit_number AS transaction_key,
       ch.credit_number AS document_number,
       CAST ('Service Credit' AS VARCHAR (50)) AS document_type,
       ch.internal_note,
       ch.row_modified_datetime
FROM   [int].[order_credit_header] AS ch
       LEFT OUTER JOIN
       [int].[order_invoice_header] AS ih
       ON ch.invoice_connection_number = ih.invoice_number
WHERE  ch.invoice_connection_number IS NOT NULL
       AND ih.invoice_number IS NULL -- connection number set but not an order invoice; classify as service credit
UNION ALL
-- Till Invoices (POS sundry invoices)
SELECT 'TIL-INV-' + h.invoice_number AS transaction_key,
       h.invoice_number AS document_number,
       CAST ('Till Invoice' AS VARCHAR (50)) AS document_type,
       CAST (NULL AS VARCHAR (8000)) AS internal_note, -- POS has no internal note
       h.row_modified_datetime
FROM   [int].[pos_invoice_notes_header] AS h
UNION ALL
-- Till Credits (POS sundry credits)
SELECT 'TIL-CRD-' + h.credit_number AS transaction_key,
       h.credit_number AS document_number,
       CAST ('Till Credit' AS VARCHAR (50)) AS document_type,
       CAST (NULL AS VARCHAR (8000)) AS internal_note,
       h.row_modified_datetime
FROM   [int].[pos_credit_notes_header] AS h
UNION ALL
-- Sales Orders
-- No row_modified_datetime exists on this ERP source; NULL means "always re-include" in the loader (table is tiny, ~500 rows).
SELECT 'SAL-ORD-' + h.order_number AS transaction_key,
       h.order_number AS document_number,
       CAST ('Sales Order' AS VARCHAR (50)) AS document_type,
       h.internal_note,
       CAST (NULL AS DATETIME) AS row_modified_datetime
FROM   [stg].[sales_order_header] AS h
UNION ALL
-- Service Invoices (completed repairs that have been invoiced)
-- DISTINCT: multiple repair jobs (fault_no) can share one invoice_number; deduplicate to one row per document.
SELECT DISTINCT 'SVC-INV-' + r.invoice_number AS transaction_key,
                r.invoice_number AS document_number,
                CAST ('Service Invoice' AS VARCHAR (50)) AS document_type,
                CAST (NULL AS VARCHAR (8000)) AS internal_note,
                r.row_modified_datetime
FROM   [int].[base_repair_headers] AS r
WHERE  r.invoice_number IS NOT NULL
       AND r.invoice_number <> ''
UNION ALL
-- Service Orders (open or active repairs not yet invoiced)
-- DISTINCT: multiple line records can share one order_number; deduplicate to one row per document.
SELECT DISTINCT 'SVC-ORD-' + r.order_number AS transaction_key,
                r.order_number AS document_number,
                CAST ('Service Order' AS VARCHAR (50)) AS document_type,
                CAST (NULL AS VARCHAR (8000)) AS internal_note,
                r.row_modified_datetime
FROM   [int].[base_repair_headers] AS r
WHERE  r.invoice_number IS NULL
       OR r.invoice_number = '';