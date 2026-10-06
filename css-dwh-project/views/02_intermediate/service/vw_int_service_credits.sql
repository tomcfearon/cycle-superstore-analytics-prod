CREATE VIEW -- OR ALTER
[int].[int_service_credits]
AS
-- Dedupe employees by name to prevent LEFT JOIN fan-out (see vw_int_fact_repair_lines.sql).
WITH   deduped_employees
AS     (SELECT employee_key,
               employee_name,
               ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
        FROM   [int].[employees])
SELECT 'SVC-CRD-' + ch.credit_number AS transaction_key, -- prefixed key; replaces credit_number as the row identifier
       ch.credit_number, -- raw varchar key; exposed for incremental loader predicate pushdown
       ch.customer_code,
       CAST (ch.credit_datetime AS TIME (0)) AS credit_time,
       ch.credit_date,
       ch.invoice_connection_number, -- FK to original service invoice
       ch.order_number, -- FK to parent service order; kept as cross-entity reference
       sh.order_date, -- date the parent service order was placed; NULL if no linked order
       ch.row_modified_datetime, -- passed through from raw_ccdata.InvoiceHeader (via order_credit_header)
       ih.web_order_id,
       d.price,
       d.quantity,
       d.vat_amount,
       CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3') THEN d.[description] ELSE NULL END AS [description], -- null for real product lines; populated only for misc/placeholder keys
       d.line_sequence_number,
       -- Price before discount inc. VAT (qty × unit_price × gross-up; matches service invoice logic)
       CAST (d.unit_price_before_discount * d.quantity * (1 + CASE WHEN d.tax_code = 1 THEN 0.23 WHEN d.tax_code = 4 THEN 0.135 ELSE 0.00 END) AS DECIMAL (18, 2)) AS price_before_discount,
       d.discount_approver_id AS approver_key,
       isnull(e.employee_key, -1) AS creditor_key,
       -- Integer key of the original booking salesperson; used as the active PBI relationship to Employee
       isnull(sp.employee_key, -1) AS salesperson_employee_key,
       -- Integer key of the engineer on the connected service invoice
       isnull(eng.employee_key, -1) AS engineer_key,
       isnull(m.product_key, 'MISC-3') AS product_key,
       sh.service_type_key, -- integer FK inherited from the linked service invoice's repair header
       CASE WHEN (d.cost IS NULL
                  OR d.cost = 0)
                 AND d.product_id IN ('MISC', 'SWAP', 'ORDER') THEN ((d.price - d.vat_amount) / 2.0) ELSE isnull(d.cost, 0) END AS cost
FROM   [int].[order_credit_header] AS ch
       LEFT OUTER JOIN
       deduped_employees AS e
       ON ch.salesperson_name = e.employee_name
          AND e.rn = 1
       LEFT OUTER JOIN
       [int].[base_repair_headers] AS sh
       ON ch.invoice_connection_number = sh.invoice_number
       -- Resolve the booking salesperson name to an integer key for PBI relationship correctness
       LEFT OUTER JOIN
       deduped_employees AS sp
       ON sh.salesperson_name = sp.employee_name
          AND sp.rn = 1
       -- Resolve the engineer name from the connected service repair header to an integer key
       LEFT OUTER JOIN
       deduped_employees AS eng
       ON sh.engineer_name = eng.employee_name
          AND eng.rn = 1
       LEFT OUTER JOIN
       [int].[order_invoice_header] AS ih
       ON ch.invoice_connection_number = ih.invoice_number
       LEFT OUTER JOIN
       [int].[order_credit_details] AS d
       ON ch.credit_number = d.credit_number
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.product_id
WHERE  sh.invoice_number IS NOT NULL -- Repair-linked; mirrors int_order_credits' rh.invoice_number IS NULL so the two views never overlap
       OR EXISTS ( -- Fallback: the linked repair invoice can be missing/purged from source, but a SER-prefixed line (service labour code) still proves this is a service credit
           SELECT 1
           FROM   [int].[order_credit_details] AS sd
           WHERE  sd.credit_number = ch.credit_number
                  AND sd.product_id LIKE 'SER%'
       );