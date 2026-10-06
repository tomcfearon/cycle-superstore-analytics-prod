CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_purchase_orders];
[marts].[usp_load_fct_purchase_orders]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS SYSNAME = 'marts.usp_load_fct_purchase_orders';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_inserted AS INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        TRUNCATE TABLE [marts].[fct_purchase_orders];
        INSERT INTO [marts].[fct_purchase_orders] (
            product_key,
            order_number,
            order_date,
            due_in_date,
            goods_in_datetime,
            supplier_code,
            purchase_order_employee_key,
            goods_in_employee_key,
            line_number,
            item_type,
            stock_location,
            quantity,
            quantity_received,
            cost,
            retail_price,
            trade_price
        )
        SELECT product_key,
               order_number,
               order_date,
               due_in_date,
               goods_in_datetime,
               supplier_code,
               purchase_order_employee_key,
               goods_in_employee_key,
               line_number,
               item_type,
               stock_location,
               quantity,
               quantity_received,
               cost,
               retail_price,
               trade_price
        FROM   [marts].[vw_fct_purchase_orders];
        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        MERGE INTO [meta].[refresh_metadata]
         AS tgt
        USING (SELECT N'marts.fct_purchase_orders' AS table_name) AS src ON tgt.table_name = src.table_name
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