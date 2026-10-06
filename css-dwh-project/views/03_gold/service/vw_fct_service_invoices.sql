CREATE
-- OR ALTER
VIEW [marts].[vw_fct_service_invoices] AS
SELECT
        transaction_key,
        order_number,   -- FK to parent service order; kept as cross-entity reference
        customer_code,
        -- Keys
        salesperson_key,
        engineer_key,
        supervisor_key,
        approver_key,
        product_key,
        web_service_booking_id AS web_order_id,
        service_bike_id,
        -- Dates
        order_date,
        invoice_date,
        repair_date,
        completion_date,
        collection_date,
        row_modified_datetime, -- ERP-stamped datetime from raw_ccdata.Repairs
        -- Status & Flags
        invoice_status,
        CAST(is_urgent AS bit) AS is_urgent,
        CAST(is_faulty AS bit) AS is_faulty,
        CAST(is_credited AS bit) AS is_credited,
        -- Metrics
        estimate_given,
        total_labour_cost,
        payment_to_date,
        credit_note_number,
        credit_number,
        quantity,
        -- Financials
        price,
        vat_amount,
        price_before_discount,
        cost,
        repair_time,
        -- Meta
        [description] AS description,
        ISNULL(line_sequence_number, 0) AS line_sequence_number,
        is_company_stock,
        is_wheel,
        is_fork,
        is_pedal,
        service_type_key, -- integer FK assigned upstream in int.base_repair_headers
        bike_brand,
        misc_title,
        CAST(CASE WHEN web_service_booking_id IS NOT NULL THEN 'Web' ELSE 'In-Store' END AS varchar(50)) AS order_channel
    FROM
        [int].[int_service_invoices];
