CREATE VIEW --OR ALTER 
[int].[int_service_invoices]
AS
SELECT 'SVC-INV-' + invoice_number AS transaction_key, -- prefixed key; replaces invoice_number as the row identifier
       order_number, -- FK to parent service order; kept as cross-entity reference
       order_date,
       repair_date,
       completion_date,
       service_bike_id,
       invoice_date,
       collection_date,
       customer_code,
       repair_status AS invoice_status,
       total_labour_cost,
       payment_to_date,
       credit_note_number,
       repair_time,
       estimate_given,
       is_urgent,
       is_faulty,
       supervisor_key,
       web_service_booking_id,
       quantity,
       vat_amount,
       [description],
       -- Recomputed (not passed through): ERP occasionally reuses one invoice_number across multiple repair orders (fault_no), which would otherwise duplicate the raw per-order group_seq_no and violate the fct_service_invoices grain.
       CAST (ROW_NUMBER() OVER (PARTITION BY invoice_number ORDER BY order_number, line_sequence_number) AS INT) AS line_sequence_number,
       approver_key,
       is_credited,
       credit_number,
       salesperson_key,
       engineer_key,
       product_key,
       price_inc_vat AS price,
       price_before_discount,
       cost,
       is_company_stock,
       is_wheel,
       is_fork,
       is_pedal,
       service_type_key,
       bike_brand,
       misc_title,
       row_modified_datetime
FROM   [int].[fact_repair_lines]
WHERE  invoice_number IS NOT NULL
       AND invoice_number <> '';