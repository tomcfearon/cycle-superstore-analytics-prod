CREATE VIEW -- OR ALTER
[int].[int_pos_invoices]
AS
-- Dedupe employees by name to prevent LEFT JOIN fan-out (see vw_int_fact_repair_lines.sql).
WITH   deduped_employees
AS     (SELECT employee_key,
               employee_name,
               ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
        FROM   [int].[employees])
SELECT 'Till Invoice' AS transaction_type,
       'TIL-INV-' + d.invoice_number AS transaction_key, -- prefixed key for till invoice source documents
       h.invoice_date AS receipt_date,
       h.customer_code,
       isnull(e.employee_key, -1) AS salesperson_key,
       isnull(m.product_key, 'MISC-3') AS product_key,
       d.quantity,
       d.price,
       d.vat_amount,
       CASE WHEN (d.cost IS NULL
                  OR d.cost = 0)
                 AND d.product_id IN ('MISC', 'SWAP', 'ORDER', 'DISC', 'ORDERMAIN') THEN ROUND(CASE WHEN isnull(d.quantity, 0) <> 0 THEN ((d.price - d.vat_amount) / d.quantity) / 2.0 ELSE 0 END, 2) * isnull(d.quantity, 0) ELSE isnull(d.cost, 0) END AS cost,
       (d.unit_price_before_discount * d.quantity) AS price_before_discount,
       d.line_sequence_number,
       CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3') THEN d.[description] ELSE NULL END AS [description], -- null for real product lines; populated only for misc/placeholder keys
       CAST (0 AS BIT) AS is_from_credit_note
FROM   [int].[pos_invoice_notes_details] AS d
       INNER JOIN
       [int].[pos_invoice_notes_header] AS h
       ON d.invoice_number = h.invoice_number
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.product_id
       LEFT OUTER JOIN
       deduped_employees AS e
       ON h.salesperson_name = e.employee_name
          AND e.rn = 1
WHERE  (CASE WHEN d.is_credited = 1
                  OR d.quantity < 0 THEN -isnull(d.price, 0) ELSE isnull(d.price, 0) END) > 0 -- Classify invoice-note rows by effective ERP sign instead of refund flag alone.
UNION ALL
SELECT 'Till Invoice' AS transaction_type,
       'TIL-CRD-' + d.credit_number AS transaction_key, -- prefixed key reflecting the source credit note document
       h.credit_date AS receipt_date,
       h.customer_code,
       isnull(e.employee_key, -1) AS salesperson_key,
       isnull(m.product_key, 'MISC-3') AS product_key,
       d.quantity,
       d.price,
       d.vat_amount,
       CASE WHEN (d.cost IS NULL
                  OR d.cost = 0)
                 AND d.product_id IN ('MISC', 'SWAP', 'ORDER', 'DISC', 'ORDERMAIN') THEN ROUND(CASE WHEN isnull(d.quantity, 0) <> 0 THEN ((d.price - d.vat_amount) / d.quantity) / 2.0 ELSE 0 END, 2) * isnull(d.quantity, 0) ELSE isnull(d.cost, 0) END AS cost,
       (d.unit_price_before_discount * d.quantity) AS price_before_discount,
       d.line_sequence_number,
       CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3') THEN d.[description] ELSE NULL END AS [description], -- null for real product lines; populated only for misc/placeholder keys
       CAST (1 AS BIT) AS is_from_credit_note
FROM   [int].[pos_credit_notes_details] AS d
       INNER JOIN
       [int].[pos_credit_notes_header] AS h
       ON d.credit_number = h.credit_number
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.product_id
       LEFT OUTER JOIN
       deduped_employees AS e
       ON h.salesperson_name = e.employee_name
          AND e.rn = 1
WHERE  (CASE WHEN d.is_credited = 1
                  OR d.quantity < 0 THEN -isnull(d.price, 0) ELSE isnull(d.price, 0) END) > 0; -- Apply the same refund-item sign logic as ERP so only positive salesperson till rows stay in the invoice stream.