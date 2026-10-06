CREATE VIEW --OR ALTER 
[int].[int_service_orders]
AS
SELECT 'SVC-ORD-' + order_number AS transaction_key, -- prefixed key; replaces order_number as the row identifier
       order_date,
       repair_date,
       collection_date,
       customer_code,
       engineer_key,
       service_bike_id,
       repair_status AS order_status,
       total_labour_cost,
       repair_time,
       estimate_given,
       is_urgent,
       is_faulty,
       supervisor_key,
       web_service_booking_id,
       quantity,
       vat_amount,
       [description],
       ISNULL(line_sequence_number, 0) AS line_sequence_number,
       approver_key,
       salesperson_key,
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
WHERE  (invoice_number IS NULL
        OR invoice_number = '');