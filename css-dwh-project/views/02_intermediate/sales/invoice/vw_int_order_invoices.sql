CREATE VIEW -- OR ALTER
[int].[int_order_invoices]
AS
-- Dedupe employees by name to prevent LEFT JOIN fan-out (see vw_int_fact_repair_lines.sql).
WITH   deduped_employees
AS     (SELECT employee_key,
               employee_name,
               ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
        FROM   [int].[employees])
SELECT 'ORD-INV-' + h.invoice_number AS transaction_key, -- prefixed key; replaces invoice_number as the row identifier
       h.customer_code,
       CAST (h.invoice_datetime AS TIME (0)) AS invoice_time,
       h.invoice_date,
       h.order_number, -- FK to linked sales order; kept as cross-entity reference
       CAST (isnull(h.order_datetime, h.invoice_date) AS TIME (0)) AS order_time,
       CAST (isnull(h.order_datetime, h.invoice_date) AS DATE) AS order_date,
       h.web_order_id,
       h.row_modified_datetime, -- passed through from raw_ccdata.InvoiceHeader
       d.price,
       d.quantity,
       d.vat_amount,
       h.is_dispatched,
       CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3') THEN d.[description] ELSE NULL END AS [description], -- null for real product lines; populated only for misc/placeholder keys
       d.line_sequence_number,
       d.credit_note_number,
       d.is_credited,
       d.discount_approver_id AS approver_key,
       isnull(e.employee_key, -1) AS salesperson_key,
       h.collection_employee_key,
       isnull(m.product_key, 'MISC-3') AS product_key,
       (d.unit_price_before_discount * d.quantity) AS price_before_discount,
       CASE WHEN (d.cost IS NULL
                  OR d.cost = 0)
                 AND d.product_id IN ('MISC', 'SWAP', 'ORDER', 'DISC', 'ORDERMAIN') THEN ROUND(CASE WHEN isnull(d.quantity, 0) <> 0 THEN ((d.price - d.vat_amount) / d.quantity) / 2.0 ELSE 0 END, 2) * isnull(d.quantity, 0) ELSE isnull(d.cost, 0) END AS cost
FROM   [int].[order_invoice_header] AS h
       LEFT OUTER JOIN
       [int].[order_invoice_details] AS d
       ON h.invoice_number = d.invoice_number
       LEFT OUTER JOIN
       deduped_employees AS e
       ON h.salesperson_name = e.employee_name
          AND e.rn = 1
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.product_id;