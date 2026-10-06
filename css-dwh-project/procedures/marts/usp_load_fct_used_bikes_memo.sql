CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_used_bikes_memo];
[marts].[usp_load_fct_used_bikes_memo]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_fct_used_bikes_memo';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_inserted AS INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        TRUNCATE TABLE [marts].[fct_used_bikes_memo];
        INSERT INTO [marts].[fct_used_bikes_memo] (
            used_bike_id,
            service_order_number,
            web_bike_id,
            memo_date,
            sold_date,
            customer_code,
            sold_customer_code,
            salesperson1_key,
            salesperson2_key,
            sold_salesperson_key,
            description,
            brand,
            product_key,
            retail_price,
            cost_price,
            sale_price,
            sold_price,
            sold_payment_amount,
            service_cost_price,
            used_bike_status,
            used_bike_category,
            web_status,
            order_channel
        )
        SELECT used_bike_id,
               service_order_number,
               web_bike_id,
               memo_date,
               sold_date,
               customer_code,
               sold_customer_code,
               salesperson1_key,
               salesperson2_key,
               sold_salesperson_key,
               description,
               brand,
               product_key,
               retail_price,
               cost_price,
               sale_price,
               sold_price,
               sold_payment_amount,
               service_cost_price,
               used_bike_status,
               used_bike_category,
               web_status,
               order_channel
        FROM   [marts].[vw_fct_used_bikes_memo];
        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        MERGE INTO [meta].[refresh_metadata]
         AS tgt
        USING (SELECT N'marts.fct_used_bikes_memo' AS table_name) AS src ON tgt.table_name = src.table_name
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