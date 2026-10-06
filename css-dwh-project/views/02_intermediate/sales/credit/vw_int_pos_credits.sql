CREATE VIEW -- OR ALTER
[int].[int_pos_credits]
AS
-- Dedupe employees by name to prevent LEFT JOIN fan-out (see vw_int_fact_repair_lines.sql).
WITH   deduped_employees
AS     (SELECT employee_key,
               employee_name,
               ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
        FROM   [int].[employees])
SELECT 'Till Credit' AS transaction_type,
       'TIL-INV-' + d.invoice_number AS transaction_key, -- prefixed key for till invoice source documents
       h.invoice_date AS receipt_date,
       h.customer_code,
       CASE WHEN d.is_credited = 1 THEN -1 ELSE isnull(e.employee_key, -1) END AS salesperson_key, -- Match ERP sundry attribution by routing only explicit refund rows to Shop.
       isnull(m.product_key, 'MISC-3') AS product_key,
       isnull(d.quantity, 0) AS quantity,
       isnull(d.price, 0) AS price,
       isnull(d.vat_amount, 0) AS vat_amount,
       isnull(d.cost, 0) AS cost,
       isnull(d.unit_price_before_discount, 0) * isnull(d.quantity, 0) AS price_before_discount,
       d.line_sequence_number,
       CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3') THEN d.[description] ELSE NULL END AS [description], -- null for real product lines; populated only for misc/placeholder keys
       CAST (1 AS BIT) AS is_from_invoice_note
FROM   [int].[pos_invoice_notes_details] AS d
       INNER JOIN
       [int].[pos_invoice_notes_header] AS h
       ON d.invoice_number = h.invoice_number
       LEFT OUTER JOIN
       deduped_employees AS e
       ON h.salesperson_name = e.employee_name
          AND e.rn = 1
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.product_id
WHERE  (CASE WHEN d.is_credited = 1
                  OR d.quantity < 0 THEN -isnull(d.price, 0) ELSE isnull(d.price, 0) END) < 0 -- Classify invoice-note rows by effective ERP sign instead of refund flag alone.
UNION ALL
SELECT 'Till Credit' AS transaction_type,
       'TIL-CRD-' + d.credit_number AS transaction_key, -- prefixed key reflecting the source credit note document
       h.credit_date AS receipt_date,
       h.customer_code,
       CASE WHEN d.is_credited = 1 THEN -1 ELSE isnull(e.employee_key, -1) END AS salesperson_key, -- Match ERP sundry attribution by routing only explicit refund rows to Shop.
       isnull(m.product_key, 'MISC-3') AS product_key,
       isnull(d.quantity, 0) AS quantity,
       isnull(d.price, 0) AS price,
       isnull(d.vat_amount, 0) AS vat_amount,
       isnull(d.cost, 0) AS cost,
       isnull(d.unit_price_before_discount, 0) * isnull(d.quantity, 0) AS price_before_discount,
       d.line_sequence_number,
       CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3') THEN d.[description] ELSE NULL END AS [description], -- null for real product lines; populated only for misc/placeholder keys
       CAST (0 AS BIT) AS is_from_invoice_note
FROM   [int].[pos_credit_notes_details] AS d
       INNER JOIN
       [int].[pos_credit_notes_header] AS h
       ON d.credit_number = h.credit_number
       LEFT OUTER JOIN
       deduped_employees AS e
       ON h.salesperson_name = e.employee_name
          AND e.rn = 1
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.product_id
WHERE  (CASE WHEN d.is_credited = 1
                  OR d.quantity < 0 THEN -isnull(d.price, 0) ELSE isnull(d.price, 0) END) < 0; -- Apply the same refund-item sign logic as ERP so negative Shop till rows stay in the credit stream.