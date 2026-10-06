CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file:
-- EXEC [marts].[usp_load_warehouse_dimensions] @ForceFullLoad = 0;
[marts].[usp_load_warehouse_dimensions]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        EXECUTE [marts].[usp_load_dim_customer] @ForceFullLoad = @ForceFullLoad; --incremental 
        EXECUTE [marts].[usp_load_dim_employee] ;
        EXECUTE [marts].[usp_load_dim_product] @ForceFullLoad = @ForceFullLoad; --incremental 
        EXECUTE [marts].[usp_load_dim_transaction] @ForceFullLoad = @ForceFullLoad; --incremental 
    END TRY
    BEGIN CATCH
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT('marts.usp_load_warehouse_dimensions failed: ', ERROR_MESSAGE());
        THROW 51000, @error_message, 1;
    END CATCH
END