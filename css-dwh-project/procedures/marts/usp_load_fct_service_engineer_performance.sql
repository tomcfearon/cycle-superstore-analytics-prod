CREATE
-- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_service_engineer_performance];
PROCEDURE [marts].[usp_load_fct_service_engineer_performance]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @proc_name sysname = 'marts.usp_load_fct_service_engineer_performance';
    DECLARE @started_at datetime2(3) = SYSDATETIME();
    DECLARE @rows_affected int = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Reload the engineer performance fact from the mart view so the ERP-derived aggregates stay consistent.
        TRUNCATE TABLE [marts].[fct_service_engineer_performance];

        INSERT INTO [marts].[fct_service_engineer_performance]
        (
            activity_date,
            engineer_key,
            bike_build_count,
            bike_build_time_spent,
            floor_bike_build_count,
            floor_bike_build_time_spent,
            repair_time_spent
        )
        SELECT
            activity_date,
            engineer_key,
            bike_build_count,
            bike_build_time_spent,
            floor_bike_build_count,
            floor_bike_build_time_spent,
            repair_time_spent
        FROM [marts].[vw_fct_service_engineer_performance];

        SET @rows_affected = @@ROWCOUNT;

        COMMIT TRANSACTION;

        MERGE [meta].[refresh_metadata] AS tgt
        USING (SELECT N'marts.fct_service_engineer_performance' AS table_name) AS src
            ON tgt.table_name = src.table_name
        WHEN MATCHED THEN
            UPDATE SET
                refresh          = tgt.refresh + 1,
                last_refresh_utc = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (table_name, layer_name, refresh, last_refresh_utc)
            VALUES (src.table_name, N'marts', 1, SYSUTCDATETIME());

        PRINT CONCAT(
            @proc_name,
            ' succeeded. Rows inserted: ',
            @rows_affected,
            '. Duration (ms): ',
            DATEDIFF(ms, @started_at, SYSDATETIME())
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @error_message nvarchar(4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());

        THROW 50000, @error_message, 1;
    END CATCH
END;
