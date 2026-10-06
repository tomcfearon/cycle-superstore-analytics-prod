CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_sales_orders];
[marts].[usp_load_fct_sales_orders]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_fct_sales_orders';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_inserted AS INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        TRUNCATE TABLE [marts].[fct_sales_orders];
        INSERT INTO [marts].[fct_sales_orders] (
            transaction_key,
            order_time,
            order_date,
            employee_key,
            customer_code,
            deposit_value,
            payment_to_date,
            collection_date,
            box_number,
            order_status,
            web_order_id,
            is_confirmed,
            bike_location,
            product_key,
            price,
            quantity,
            vat_amount,
            cost,
            description,
            line_sequence_number,
            quantity_taken,
            price_before_discount,
            request_id,
            is_pulled,
            approver_key,
            order_channel,
            collection_employee_key
        )
        SELECT transaction_key,
               order_time,
               order_date,
               employee_key,
               customer_code,
               deposit_value,
               payment_to_date,
               collection_date,
               box_number,
               order_status,
               web_order_id,
               is_confirmed,
               bike_location,
               product_key,
               price,
               quantity,
               vat_amount,
               cost,
               description,
               line_sequence_number,
               quantity_taken,
               price_before_discount,
               request_id,
               is_pulled,
               approver_key,
               order_channel,
               collection_employee_key
        FROM   [marts].[vw_fct_sales_orders];
        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        MERGE INTO [meta].[refresh_metadata]
         AS tgt
        USING (SELECT N'marts.fct_sales_orders' AS table_name) AS src ON tgt.table_name = src.table_name
        WHEN MATCHED THEN UPDATE 
        SET refresh          = tgt.refresh + 1,
            last_refresh_utc = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN INSERT (
            table_name,
            layer_name,
            refresh,
            last_refresh_utc
        ) VALUES (src.table_name, N'marts', 1, SYSUTCDATETIME());
        PRINT CONCAT(@proc_name, ' succeeded. Rows inserted: ', @rows_inserted, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END