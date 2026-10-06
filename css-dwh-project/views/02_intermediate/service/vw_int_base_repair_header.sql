CREATE VIEW -- OR ALTER
[int].[base_repair_headers]
AS
WITH-- Deduplicate service_product by product_id to prevent LEFT JOIN fan-out.
-- stg.product can contain duplicate product_id rows; taking the first row per
-- product_id ensures this join never expands the repair header row count.
       deduped_service_product
AS     (SELECT product_id,
               title,
               is_company_stock,
               is_wheel,
               is_fork,
               is_pedal,
               brand,
               ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY (SELECT NULL)) AS rn
        FROM   [int].[service_product])
SELECT r.fault_no AS order_number,
       r.invoice_no AS invoice_number,
       -- Date Logic
       CAST (r.fault_date AS DATE) AS order_date,
       CAST (r.repair_date AS DATE) AS repair_date,
       CAST (r.date_completed AS DATE) AS completion_date,
       CAST (r.invoice_date AS DATE) AS invoice_date,
       CAST (r.collect_date AS DATE) AS collection_date,
       -- Customer & Staff
       r.customer_code,
       r.service_bike_id,
       r.salesperson AS salesperson_name,
       NULLIF (r.engineer, '') AS engineer_name,
       NULLIF (r.manager_check_user_id, 0) AS supervisor_id,
       -- Status Logic (Unified)
       CASE WHEN r.current_status = '5-Ready for collection' THEN 'Ready for collection' WHEN r.current_status = '3 - To be Repaired' THEN 'To be repaired' WHEN r.current_status = '3-To be Repaired' THEN 'To be repaired' WHEN r.current_status = '1-Pre- booked' THEN 'Repair in progress' WHEN r.current_status = '7-COLLECTED' THEN 'Collected' WHEN r.current_status = '8-Repair Cancelled' THEN 'Repair cancelled' ELSE ISNULL(NULLIF (r.current_status, ''), 'Not Set') END AS repair_status, -- Handling inconsistent spacing in source
       -- Or Pre-booked, normalized to one
       -- Financials & Metrics
       r.total_labour AS total_labour_cost,
       r.payment_to_date,
       CASE WHEN r.time_spent < 0 THEN 0 ELSE r.time_spent END AS repair_time,
       NULLIF (r.refund_no, '') AS credit_note_number,
       NULLIF (TRIM(r.cust_estimate), '') AS estimate_given,
       -- Flags & IDs
       r.urgent AS is_urgent,
       CASE WHEN r.trans_type = 1 THEN 0 ELSE 1 END AS is_faulty,
       r.web_service_booked_id AS web_service_booking_id,
       d.title AS misc_title,
       d.is_company_stock,
       d.is_wheel,
       d.is_fork,
       d.is_pedal,
       d.brand,
       -- Service type key: integer FK matching dim_service_type (keys 1-6, -1=Unclassified).
       -- No Data (4) when no bike is linked; non-SER code = confirmed brand stock (1).
       -- Component priority: Fork (3) > Wheel (6) > Pedal (5); whole-bike fallbacks Brand Bike (1) / Customer Bike (2).
       CASE WHEN NULLIF (r.service_bike_id, '') IS NULL THEN 4 WHEN r.service_bike_id NOT LIKE 'SER-%' THEN 1 WHEN d.is_fork = 1 THEN 3 WHEN d.is_wheel = 1 THEN 6 WHEN d.is_pedal = 1 THEN 5 WHEN d.is_company_stock = 1 THEN 1 ELSE 2 END AS service_type_key, -- No linked bike       → No Data
       -- Real stock code       → Brand Bike
       -- Fork component        → Fork
       -- Wheel component       → Wheel
       -- Pedal component       → Pedal
       -- Company stock bike    → Brand Bike
       -- Customer's own bike  → Customer Bike
       r.row_modified_datetime AS row_modified_datetime
FROM   [stg].[repairs_header] AS r
       LEFT OUTER JOIN
       deduped_service_product AS d
       ON r.service_bike_id = d.product_id
          AND d.rn = 1;


-- Common filter applied once