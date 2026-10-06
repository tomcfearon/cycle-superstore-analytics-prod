CREATE VIEW -- OR ALTER
[int].[int_order_credits]
AS
-- Dedupe employees by name to prevent LEFT JOIN fan-out (see vw_int_fact_repair_lines.sql).
WITH   deduped_employees
AS     (SELECT employee_key,
               employee_name,
               ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
        FROM   [int].[employees])
SELECT 'ORD-CRD-' + ch.credit_number AS transaction_key, -- prefixed key; replaces credit_number as the row identifier
       ch.customer_code,
       CAST (ch.credit_datetime AS TIME (0)) AS credit_time,
       ch.credit_date,
       ch.invoice_connection_number, -- FK to original order invoice
       ch.order_number, -- FK to linked sales order; kept as cross-entity reference
       ch.row_modified_datetime, -- passed through from raw_ccdata.InvoiceHeader
       ih.web_order_id,
       ch.collection_employee_key,
       d.price,
       d.quantity,
       d.vat_amount,
       CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3') THEN d.[description] ELSE NULL END AS [description], -- null for real product lines; populated only for misc/placeholder keys
       d.line_sequence_number,
       d.discount_approver_id AS approver_key,
       isnull(e.employee_key, -1) AS salesperson_key,
       isnull(sk.employee_key, -1) AS invoice_salesperson_key,
       isnull(m.product_key, 'MISC-3') AS product_key,
       CASE WHEN (d.cost IS NULL
                  OR d.cost = 0)
                 AND d.product_id IN ('MISC', 'SWAP', 'ORDER', 'DISC', 'ORDERMAIN') THEN ((d.price - d.vat_amount) / 2.0) ELSE isnull(d.cost, 0) END AS cost,
       (d.unit_price_before_discount * d.quantity) AS price_before_discount
FROM   [int].[order_credit_header] AS ch
       LEFT OUTER JOIN
       deduped_employees AS e
       ON ch.salesperson_name = e.employee_name
          AND e.rn = 1
       LEFT OUTER JOIN
       [int].[order_invoice_header] AS ih
       ON ch.invoice_connection_number = ih.invoice_number
       LEFT OUTER JOIN
       deduped_employees AS sk
       ON ih.salesperson_name = sk.employee_name
          AND sk.rn = 1
       LEFT OUTER JOIN
       [int].[base_repair_headers] AS rh
       ON ch.invoice_connection_number = rh.invoice_number -- Keep repair-linked credits out of the sales-credit stream because ERP reports them in service, not sales.
       LEFT OUTER JOIN
       [int].[order_credit_details] AS d
       ON ch.credit_number = d.credit_number
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.product_id
WHERE  rh.invoice_number IS NULL -- Match the ERP salesperson report, which excludes credits linked back to repair invoices.
       AND NOT EXISTS ( -- Fallback: the linked repair invoice can be missing/purged from source, but a SER-prefixed line (service labour code) still proves this is a service credit
           SELECT 1
           FROM   [int].[order_credit_details] AS sd
           WHERE  sd.credit_number = ch.credit_number
                  AND sd.product_id LIKE 'SER%'
       );