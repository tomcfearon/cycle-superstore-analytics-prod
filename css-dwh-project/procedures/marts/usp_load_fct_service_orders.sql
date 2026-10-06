CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_service_orders];
[marts].[usp_load_fct_service_orders]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_fct_service_orders';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_inserted AS INT = 0;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Always Full Load: empty the table and pull everything
        TRUNCATE TABLE [marts].[fct_service_orders];
        INSERT INTO [marts].[fct_service_orders] (
            transaction_key,
            order_date,
            repair_date,
            collection_date,
            customer_code,
            salesperson_key,
            engineer_key,
            supervisor_key,
            product_key,
            approver_key,
            web_order_id,
            service_bike_id,
            order_status,
            is_urgent,
            is_faulty,
            total_labour_cost,
            repair_time,
            estimate_given,
            quantity,
            price,
            vat_amount,
            price_before_discount,
            cost,
            description,
            line_sequence_number,
            row_modified_datetime,
            is_company_stock,
            is_wheel,
            is_fork,
            is_pedal,
            service_type_key,
            bike_brand,
            misc_title,
            order_channel
        )
        SELECT transaction_key,
               order_date,
               repair_date,
               collection_date,
               customer_code,
               salesperson_key,
               engineer_key,
               supervisor_key,
               product_key,
               approver_key,
               web_order_id,
               service_bike_id,
               order_status,
               is_urgent,
               is_faulty,
               total_labour_cost,
               repair_time,
               estimate_given,
               quantity,
               price,
               vat_amount,
               price_before_discount,
               cost,
               description,
               line_sequence_number,
               row_modified_datetime,
               is_company_stock,
               is_wheel,
               is_fork,
               is_pedal,
               service_type_key,
               bike_brand,
               misc_title,
               order_channel
        FROM   [marts].[vw_fct_service_orders];
        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- Truncate wipes the histogram; force a fresh scan so the optimizer isn't left with stale/empty stats
        UPDATE STATISTICS [marts].[fct_service_orders]
            WITH FULLSCAN;
        EXECUTE (N'EXEC sp_recompile N''[marts].[fct_service_orders]'';');
        PRINT CONCAT(@proc_name, ' succeeded. Rows inserted: ', @rows_inserted, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END