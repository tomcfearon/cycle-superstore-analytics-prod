CREATE PROCEDURE --OR ALTER
[int].[usp_load_service_product]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'int.usp_load_service_product';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_affected AS INT;
    DECLARE @last_refresh AS DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- 1. Handle the High Water Mark
        IF @ForceFullLoad = 1
            BEGIN
                -- Override mode: Empty the table and pull everything
                TRUNCATE TABLE [int].[service_product];
                SET @last_refresh = '1900-01-01';
            END
        ELSE
            BEGIN
                -- Standard incremental mode: Grab the log minus a 1-hour buffer
                SELECT @last_refresh = COALESCE (DATEADD(hour, -1, MAX(last_refresh_utc)), '1900-01-01')
                FROM   [meta].[refresh_metadata]
                WHERE  table_name = 'int.service_product';
            END
        -- 2. Upsert using MERGE
        MERGE INTO [int].[service_product]
         AS tgt
        USING (SELECT product_id,
                      title,
                      row_modified_datetime,
                      model_year,
                      brand,
                      is_company_stock,
                      is_wheel,
                      is_fork,
                      is_pedal
               FROM   [int].[vw_int_service_product]
               WHERE  row_modified_datetime >= @last_refresh) AS src ON tgt.product_id = src.product_id
        WHEN MATCHED THEN UPDATE 
        SET tgt.title                 = src.title,
            tgt.row_modified_datetime = src.row_modified_datetime,
            tgt.model_year            = src.model_year,
            tgt.brand                 = src.brand,
            tgt.is_company_stock      = src.is_company_stock,
            tgt.is_wheel              = src.is_wheel,
            tgt.is_fork               = src.is_fork,
            tgt.is_pedal              = src.is_pedal
        WHEN NOT MATCHED BY TARGET THEN INSERT (
            product_id,
            title,
            row_modified_datetime,
            model_year,
            brand,
            is_company_stock,
            is_wheel,
            is_fork,
            is_pedal
        ) VALUES (src.product_id, src.title, src.row_modified_datetime, src.model_year, src.brand, src.is_company_stock, src.is_wheel, src.is_fork, src.is_pedal);
        SET @rows_affected = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- 3. Conditionally heal statistics after a full truncation
        IF @ForceFullLoad = 1
            BEGIN
                UPDATE STATISTICS [int].[service_product]
                    WITH FULLSCAN;
                EXECUTE (N'EXEC sp_recompile N''[int].[service_product]'';');
            END
        -- 4. Log the successful refresh
        EXECUTE [meta].[usp_log_refresh] @table_name = 'int.service_product';
        PRINT CONCAT(@proc_name, ' succeeded. Rows merged: ', @rows_affected, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END
