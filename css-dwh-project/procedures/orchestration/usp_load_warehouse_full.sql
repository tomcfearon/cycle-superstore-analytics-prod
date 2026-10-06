CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [dbo].[usp_load_warehouse_full];
[dbo].[usp_load_warehouse_full]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'dbo.usp_load_warehouse_full';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    BEGIN TRY
        PRINT CONCAT(@proc_name, ' started.');
        -- Step 1: Materialised int tables (must run before any mart loader)
        EXECUTE [int].[usp_load_warehouse_int] ;
        -- Step 2: Load conformed dimensions
        EXECUTE [marts].[usp_load_warehouse_dimensions] ;
        -- Step 3: Load all fact tables
        EXECUTE [marts].[usp_load_warehouse_facts] ;
        PRINT CONCAT(@proc_name, ' completed. Total duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT('dbo.usp_load_warehouse_full failed: ', ERROR_MESSAGE());
        THROW 51000, @error_message, 1;
    END CATCH
END