CREATE VIEW --OR ALTER 
[int].[fact_repair_lines]
AS
-- Deduplicate employees by name to prevent LEFT JOIN fan-out; int.employees can contain
-- casing-variant duplicate rows for the same person (same employee_reference_number).
-- Highest employee_key wins as the most recently created/latest record.
WITH   deduped_employees
AS     (SELECT employee_key,
               employee_name,
               ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
        FROM   [int].[employees])
SELECT -- Header Info
       h.order_number,
       h.invoice_number,
       h.order_date,
       h.repair_date,
       h.completion_date,
       h.invoice_date,
       h.collection_date,
       h.customer_code,
       h.repair_status,
       -- Normalized status
       h.is_urgent,
       h.is_faulty,
       h.estimate_given,
       h.web_service_booking_id,
       -- Header Metrics
       h.total_labour_cost,
       h.payment_to_date,
       h.repair_time,
       h.credit_note_number,
       -- Line Info
       d.line_sequence_number,
       d.product_id,
       h.service_bike_id,
       h.misc_title,
       h.brand AS bike_brand,
       CAST (h.is_company_stock AS BIT) AS is_company_stock,
       CAST (h.is_wheel AS BIT) AS is_wheel,
       CAST (h.is_fork AS BIT) AS is_fork,
       CAST (h.is_pedal AS BIT) AS is_pedal, -- Preserving original data types for flags     ,
       h.service_type_key, -- integer FK assigned upstream in base_repair_headers
       -- Line Metrics
       CASE WHEN isnull(m.product_key, 'MISC-3') IN ('MISC-3', 'SWAP-3', 'DISC-3', 'OrderMain-3') THEN d.[description] ELSE NULL END AS [description], -- null for real product lines; populated only for misc/placeholder keys
       ISNULL(d.quantity, 0) AS quantity,
       ISNULL(d.vat_amount, 0) AS vat_amount,
       ISNULL(d.price_ex_vat, 0) AS price_ex_vat,
       ISNULL(d.price_ex_vat, 0) + ISNULL(d.vat_amount, 0) AS price_inc_vat,
       ISNULL(d.price_before_discount, 0) AS price_before_discount, -- upstream column from base_repair_details; qty × unit_price × VAT gross-up
       -- Complex Cost Logic (Preserved from your code)
       CASE WHEN (d.raw_cost IS NULL
                  OR d.raw_cost = 0)
                 AND d.product_id IN ('MISC', 'SWAP', 'ORDER') THEN CAST ((d.price_ex_vat) / 2 AS DECIMAL (18, 2)) ELSE CAST (d.raw_cost AS DECIMAL (18, 2)) END AS cost, -- Assuming logic was (Price - VAT) / 2 is 50% margin estimate
       -- Dimension Keys
       h.supervisor_id AS supervisor_key,
       d.discount_approver_id AS approver_key,
       ISNULL(e.employee_key, -1) AS salesperson_key,
       ISNULL(eng.employee_key, -1) AS engineer_key,
       ISNULL(m.product_key, 'MISC-3') AS product_key,
       -- Flags
       d.is_credited,
       d.credit_number,
       h.row_modified_datetime -- raw_ccdata.RepairsDetails has no row-level timestamp; header is the only available watermark
FROM   [int].[base_repair_headers] AS h
       LEFT OUTER JOIN
       [int].[base_repair_details] AS d
       ON h.order_number = d.order_number
       LEFT OUTER JOIN
       deduped_employees AS e
       ON h.salesperson_name = e.employee_name
          AND e.rn = 1
       LEFT OUTER JOIN
       deduped_employees AS eng
       ON h.engineer_name = eng.employee_name
          AND eng.rn = 1
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.product_id;