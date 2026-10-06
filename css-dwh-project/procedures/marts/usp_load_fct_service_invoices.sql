CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_service_invoices];
[marts].[usp_load_fct_service_invoices]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_fct_service_invoices';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_affected AS INT = 0;
    DECLARE @last_refresh AS DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @ForceFullLoad = 1
            BEGIN
                -- Override mode: empty the table and pull everything
                TRUNCATE TABLE [marts].[fct_service_invoices];
                SET @last_refresh = '1900-01-01';
            END
        ELSE
            BEGIN
                -- Standard incremental mode: Ask the target table exactly where it left off, minus a 1-hour buffer
                SELECT @last_refresh = COALESCE (DATEADD(hour, -1, MAX(row_modified_datetime)), '1900-01-01')
                FROM   [marts].[fct_service_invoices];
            END
        MERGE INTO [marts].[fct_service_invoices]
         AS tgt
        USING (SELECT transaction_key,
                      order_number,
                      customer_code,
                      salesperson_key,
                      engineer_key,
                      supervisor_key,
                      approver_key,
                      product_key,
                      web_order_id,
                      service_bike_id,
                      order_date,
                      invoice_date,
                      repair_date,
                      completion_date,
                      collection_date,
                      row_modified_datetime,
                      invoice_status,
                      is_urgent,
                      is_faulty,
                      is_credited,
                      estimate_given,
                      total_labour_cost,
                      payment_to_date,
                      credit_note_number,
                      credit_number,
                      quantity,
                      price,
                      vat_amount,
                      price_before_discount,
                      cost,
                      repair_time,
                      description,
                      line_sequence_number,
                      is_company_stock,
                      is_wheel,
                      is_fork,
                      is_pedal,
                      service_type_key,
                      bike_brand,
                      misc_title,
                      order_channel
               FROM   [marts].[vw_fct_service_invoices]
               WHERE  row_modified_datetime >= @last_refresh) AS src ON tgt.transaction_key = src.transaction_key -- grain: one row per invoice line
                                                                        AND tgt.line_sequence_number = src.line_sequence_number
        WHEN MATCHED THEN UPDATE 
        SET order_number          = src.order_number,
            customer_code         = src.customer_code,
            salesperson_key       = src.salesperson_key,
            engineer_key          = src.engineer_key,
            supervisor_key        = src.supervisor_key,
            approver_key          = src.approver_key,
            product_key           = src.product_key,
            web_order_id          = src.web_order_id,
            service_bike_id       = src.service_bike_id,
            order_date            = src.order_date,
            invoice_date          = src.invoice_date,
            repair_date           = src.repair_date,
            completion_date       = src.completion_date,
            collection_date       = src.collection_date,
            row_modified_datetime = src.row_modified_datetime,
            invoice_status        = src.invoice_status,
            is_urgent             = src.is_urgent,
            is_faulty             = src.is_faulty,
            is_credited           = src.is_credited,
            estimate_given        = src.estimate_given,
            total_labour_cost     = src.total_labour_cost,
            payment_to_date       = src.payment_to_date,
            credit_note_number    = src.credit_note_number,
            credit_number         = src.credit_number,
            quantity              = src.quantity,
            price                 = src.price,
            vat_amount            = src.vat_amount,
            price_before_discount = src.price_before_discount,
            cost                  = src.cost,
            repair_time           = src.repair_time,
            description           = src.description,
            is_company_stock      = src.is_company_stock,
            is_wheel              = src.is_wheel,
            is_fork               = src.is_fork,
            is_pedal              = src.is_pedal,
            service_type_key      = src.service_type_key,
            bike_brand            = src.bike_brand,
            misc_title            = src.misc_title,
            order_channel         = src.order_channel
        WHEN NOT MATCHED BY TARGET THEN INSERT (
            transaction_key,
            order_number,
            customer_code,
            salesperson_key,
            engineer_key,
            supervisor_key,
            approver_key,
            product_key,
            web_order_id,
            service_bike_id,
            order_date,
            invoice_date,
            repair_date,
            completion_date,
            collection_date,
            row_modified_datetime,
            invoice_status,
            is_urgent,
            is_faulty,
            is_credited,
            estimate_given,
            total_labour_cost,
            payment_to_date,
            credit_note_number,
            credit_number,
            quantity,
            price,
            vat_amount,
            price_before_discount,
            cost,
            repair_time,
            description,
            line_sequence_number,
            is_company_stock,
            is_wheel,
            is_fork,
            is_pedal,
            service_type_key,
            bike_brand,
            misc_title,
            order_channel
        ) VALUES (src.transaction_key, src.order_number, src.customer_code, src.salesperson_key, src.engineer_key, src.supervisor_key, src.approver_key, src.product_key, src.web_order_id, src.service_bike_id, src.order_date, src.invoice_date, src.repair_date, src.completion_date, src.collection_date, src.row_modified_datetime, src.invoice_status, src.is_urgent, src.is_faulty, src.is_credited, src.estimate_given, src.total_labour_cost, src.payment_to_date, src.credit_note_number, src.credit_number, src.quantity, src.price, src.vat_amount, src.price_before_discount, src.cost, src.repair_time, src.description, src.line_sequence_number, src.is_company_stock, src.is_wheel, src.is_fork, src.is_pedal, src.service_type_key, src.bike_brand, src.misc_title, src.order_channel);
        SET @rows_affected = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- Truncate wipes the histogram; force a fresh scan so the optimizer isn't left with stale/empty stats
        IF @ForceFullLoad = 1
            BEGIN
                UPDATE STATISTICS [marts].[fct_service_invoices]
                    WITH FULLSCAN;
                EXECUTE (N'EXEC sp_recompile N''[marts].[fct_service_invoices]'';');
            END
        PRINT CONCAT(@proc_name, ' succeeded. Rows merged: ', @rows_affected, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END