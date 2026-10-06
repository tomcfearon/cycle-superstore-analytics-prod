CREATE PROCEDURE --OR ALTER 
[int].[usp_load_product_code_mapping]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'int.usp_load_product_code_mapping';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_inserted AS INT;
    DECLARE @last_refresh AS DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @_wake AS INT;
        SELECT @_wake = 1;
        -- 1. Handle the High Water Mark
        IF @ForceFullLoad = 1
            BEGIN
                -- Override mode: Empty the table and pull everything
                TRUNCATE TABLE [int].[product_code_to_product_key_mapping];
                SET @last_refresh = '1900-01-01';
            END
        ELSE
            BEGIN
                -- Standard incremental mode: Grab the log minus a 1-hour buffer
                SELECT @last_refresh = COALESCE (DATEADD(hour, -1, MAX(last_refresh_utc)), '1900-01-01')
                FROM   [meta].[refresh_metadata]
                WHERE  table_name = 'int.product_code_to_product_key_mapping';
            END
        -- 2. Upsert using MERGE
        MERGE INTO [int].[product_code_to_product_key_mapping]
         AS tgt
        USING (SELECT product_key,
                      product_id,
                      stock_code,
                      row_modified_datetime
               FROM   [int].[vw_int_product_code_to_product_key_mapping]
               WHERE  row_modified_datetime >= @last_refresh) AS src ON tgt.product_id = src.product_id
        WHEN MATCHED THEN UPDATE 
        SET tgt.product_key           = src.product_key,
            tgt.stock_code            = src.stock_code,
            tgt.row_modified_datetime = src.row_modified_datetime
        WHEN NOT MATCHED BY TARGET THEN INSERT (
            product_key,
            product_id,
            stock_code,
            row_modified_datetime
        ) VALUES (src.product_key, src.product_id, src.stock_code, src.row_modified_datetime);
        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- 3. Conditionally heal statistics after a full truncation
        IF @ForceFullLoad = 1
            BEGIN
                UPDATE STATISTICS [int].[product_code_to_product_key_mapping]
                    WITH FULLSCAN;
                EXECUTE (N'EXEC sp_recompile N''[int].[product_code_to_product_key_mapping]'';');
            END
        -- 4. Log the successful refresh
        EXECUTE [meta].[usp_log_refresh] @table_name = 'int.product_code_to_product_key_mapping';
        PRINT CONCAT(@proc_name, ' succeeded. Rows merged: ', @rows_inserted, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END