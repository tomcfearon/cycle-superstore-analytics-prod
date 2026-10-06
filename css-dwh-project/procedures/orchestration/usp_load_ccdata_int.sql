CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file:
-- EXEC [int].[usp_load_ccdata_int] @ForceFullLoad = 0;
[int].[usp_load_ccdata_int]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'int.usp_load_ccdata_int';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    BEGIN TRY
        PRINT CONCAT(@proc_name, ' started.');
        EXECUTE [int].[usp_load_product_code_mapping] @ForceFullLoad = @ForceFullLoad;
        EXECUTE [int].[usp_load_service_product] @ForceFullLoad = @ForceFullLoad;
        PRINT CONCAT(@proc_name, ' completed. Total duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT('int.usp_load_ccdata_int failed: ', ERROR_MESSAGE());
        THROW 51000, @error_message, 1;
    END CATCH
END