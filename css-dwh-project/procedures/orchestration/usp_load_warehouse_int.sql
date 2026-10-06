CREATE PROCEDURE -- OR ALTER
--  EXEC
[int].[usp_load_warehouse_int]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_warehouse_int';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    BEGIN TRY
        PRINT CONCAT(@proc_name, ' started.');
        EXECUTE [int].[usp_load_product_code_mapping] ;
        EXECUTE [int].[usp_load_web_product_integrated] ;
        PRINT CONCAT(@proc_name, ' completed. Total duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT('int.usp_load_warehouse_int failed: ', ERROR_MESSAGE());
        THROW 51000, @error_message, 1;
    END CATCH
END