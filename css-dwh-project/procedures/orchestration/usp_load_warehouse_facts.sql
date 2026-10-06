CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file:
-- EXEC [marts].[usp_load_warehouse_facts] @ForceFullLoad = 0;
[marts].[usp_load_warehouse_facts]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_warehouse_facts';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    BEGIN TRY
        PRINT CONCAT(@proc_name, ' started.');
        EXECUTE [marts].[usp_load_fct_purchase_orders] ;
        EXECUTE [marts].[usp_load_fct_sales_orders] ;
        EXECUTE [marts].[usp_load_fct_order_invoices] @ForceFullLoad = @ForceFullLoad; --incremental 
        EXECUTE [marts].[usp_load_fct_order_credits] @ForceFullLoad = @ForceFullLoad; --incremental 
        EXECUTE [marts].[usp_load_fct_till_invoices] @ForceFullLoad = @ForceFullLoad; --incremental 
        EXECUTE [marts].[usp_load_fct_till_credits] @ForceFullLoad = @ForceFullLoad; --incremental 
        EXECUTE [marts].[usp_load_fct_service_orders] ;
        EXECUTE [marts].[usp_load_fct_service_invoices] @ForceFullLoad = @ForceFullLoad; --incremental 
        EXECUTE [marts].[usp_load_fct_service_credits] @ForceFullLoad = @ForceFullLoad; --incremental 
        -- Load the ERP-derived engineer performance fact after the service marts it depends on are ready.
        EXECUTE [marts].[usp_load_fct_service_engineer_performance] ;
        EXECUTE [marts].[usp_load_fct_used_bikes_memo] ;
        EXECUTE [marts].[usp_load_fct_exchange_emails_with_customer] ;
        -- Keep campaign-day stats separate from conversion-category stats so spend stays additive.
        EXECUTE [marts].[usp_load_fct_google_ads_campaign_daily_stats] ;
        EXECUTE [marts].[usp_load_fct_google_ads_campaign_conversions] ;
        EXECUTE [marts].[usp_load_fct_google_daily_product_performance] ;
        PRINT CONCAT(@proc_name, ' completed. Total duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT('marts.usp_load_warehouse_facts failed: ', ERROR_MESSAGE());
        THROW 51000, @error_message, 1;
    END CATCH
END