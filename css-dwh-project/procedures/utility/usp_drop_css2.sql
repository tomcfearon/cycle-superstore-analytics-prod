CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [dbo].[usp_truncate_raw_tables];
[dbo].[usp_drop_css2]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @proc_name AS sysname = 'dbo.usp_drop_css2';
    BEGIN TRY
        PRINT CONCAT(@proc_name, ' - Started at ', CONVERT (VARCHAR (30), GETDATE(), 120));
        -- Drop full-reload raw_css2 tables before ADF reload.
        IF OBJECT_ID('[raw_css2].[customers]', 'U') IS NOT NULL
            DROP TABLE [raw_css2].[customers];
        IF OBJECT_ID('[raw_css2].[products]', 'U') IS NOT NULL
            DROP TABLE [raw_css2].[products];
        -- raw_css2.categories_products is dacpac-seeded; never drop it.
        IF OBJECT_ID('[raw_css2].[ItemGroupings_T]', 'U') IS NOT NULL
            DROP TABLE [raw_css2].[ItemGroupings_T];
        IF OBJECT_ID('[raw_css2].[ProductOptions_T]', 'U') IS NOT NULL
            DROP TABLE [raw_css2].[ProductOptions_T];
        IF OBJECT_ID('[raw_css2].[SortByRelevance]', 'U') IS NOT NULL
            DROP TABLE [raw_css2].[SortByRelevance];
        -- Excluded:
        --   raw_ccdata.CategoryMap      (not loaded from ADF)
        --   raw_inventory.Inventory     (daily snapshot, keeps history)
        --   raw_365.*, raw_google.*     (separate pipelines)
        PRINT CONCAT(@proc_name, ' - Completed at ', CONVERT (VARCHAR (30), GETDATE(), 120));
    END TRY
    BEGIN CATCH
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END