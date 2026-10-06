CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_google_ads_campaign_daily_stats];
[marts].[usp_load_fct_google_ads_campaign_daily_stats]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_fct_google_ads_campaign_daily_stats';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_inserted AS INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        TRUNCATE TABLE [marts].[fct_google_ads_campaign_daily_stats];
        INSERT INTO [marts].[fct_google_ads_campaign_daily_stats] (
            campaign_id,
            stats_date,
            total_clicks,
            total_impressions,
            total_cost,
            total_interactions
        )
        SELECT campaign_id,
               stats_date,
               total_clicks,
               total_impressions,
               total_cost,
               total_interactions
        FROM   [marts].[vw_fct_google_ads_campaign_daily_stats];
        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        MERGE INTO [meta].[refresh_metadata]
         AS tgt
        USING (SELECT N'marts.fct_google_ads_campaign_daily_stats' AS table_name) AS src ON tgt.table_name = src.table_name
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