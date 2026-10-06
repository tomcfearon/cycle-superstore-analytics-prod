CREATE
-- OR ALTER
VIEW [marts].[vw_fct_service_orders] AS
SELECT
        transaction_key,
        order_date,
        repair_date,
        collection_date,
        customer_code,
        -- Keys
        salesperson_key,
        engineer_key,
        supervisor_key,
        product_key,
        approver_key,
        web_service_booking_id AS web_order_id,
        -- IDs
        service_bike_id,
        -- Added as requested
        -- Status & Flags
        order_status,
        is_urgent,
        CAST(is_faulty AS bit) AS is_faulty,
        -- Metrics
        total_labour_cost,
        repair_time,
        estimate_given,
        quantity,
        -- Financials
        price,
        vat_amount,
        price_before_discount,
        cost,
        -- Meta
        [description] AS description,
        ISNULL(line_sequence_number, 0) AS line_sequence_number, -- NULL would never match itself in the loader's MERGE, causing duplicate inserts
        row_modified_datetime, -- ERP-stamped datetime from raw_ccdata.Repairs
        is_company_stock,
        is_wheel,
        is_fork,
        is_pedal,
        service_type_key, -- integer FK assigned upstream in int.base_repair_headers
        bike_brand,
        misc_title,
        CAST(CASE WHEN web_service_booking_id IS NOT NULL THEN 'Web' ELSE 'In-Store' END AS varchar(50)) AS order_channel
    FROM
        [int].[int_service_orders];
