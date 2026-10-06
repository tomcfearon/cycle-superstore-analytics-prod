CREATE
-- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [dbo].[usp_truncate_raw_tables];
PROCEDURE [dbo].[usp_truncate_raw_tables]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @proc_name sysname = 'dbo.usp_truncate_raw_tables';

    BEGIN TRY
        PRINT CONCAT(
            @proc_name,
            ' - Started at ',
            CONVERT(VARCHAR(30), GETDATE(), 120)
        );

        -- Drop raw_ccdata tables before ADF reload.
        -- ADF copy sink (tableOption=autoCreate) recreates from the current source schema —
        -- new ERP columns land automatically without pipeline changes.
        -- DROP (not TRUNCATE) is intentional: TRUNCATE keeps the old schema and prevents
        -- autoCreate from picking up new source columns.
        IF OBJECT_ID('[raw_ccdata].[SaleOrderHeader]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[SaleOrderHeader];
        IF OBJECT_ID('[raw_ccdata].[SaleOrderDetails]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[SaleOrderDetails];
        IF OBJECT_ID('[raw_ccdata].[InvoiceDetails]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[InvoiceDetails];
        IF OBJECT_ID('[raw_ccdata].[SundryDetails]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[SundryDetails];
        IF OBJECT_ID('[raw_ccdata].[RepairsDetails]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[RepairsDetails];
        IF OBJECT_ID('[raw_ccdata].[Quotations]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[Quotations];
        IF OBJECT_ID('[raw_ccdata].[QuotationDetails]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[QuotationDetails];
        IF OBJECT_ID('[raw_ccdata].[PurchaseOrderHeader]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[PurchaseOrderHeader];
        IF OBJECT_ID('[raw_ccdata].[PurchaseOrderDetails]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[PurchaseOrderDetails];
        IF OBJECT_ID('[raw_ccdata].[Makes]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[Makes];
        IF OBJECT_ID('[raw_ccdata].[CustomerPhoneNo]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[CustomerPhoneNo];
        IF OBJECT_ID('[raw_ccdata].[AdminUsers]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[AdminUsers];
        IF OBJECT_ID('[raw_ccdata].[Events]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[Events];
        IF OBJECT_ID('[raw_ccdata].[UsedBikes]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[UsedBikes];
        IF OBJECT_ID('[raw_ccdata].[StockCountedLocations]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[StockCountedLocations];

        -- Master/reference tables moved to full-reload so ERP schema changes never break
        -- the pipeline. GetWatermark returns '1900-01-01' when absent → ADF copies all rows.
        IF OBJECT_ID('[raw_ccdata].[Stock]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[Stock];
        IF OBJECT_ID('[raw_ccdata].[Products]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[Products];
        IF OBJECT_ID('[raw_ccdata].[Customer]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[Customer];
        IF OBJECT_ID('[raw_ccdata].[Repairs]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[Repairs];

        PRINT CONCAT(@proc_name, ' - Dropped raw_ccdata tables');

        -- Drop full-reload raw_css2 tables before ADF reload.
        IF OBJECT_ID('[raw_css2].[customers]', 'U') IS NOT NULL DROP TABLE [raw_css2].[customers];
        IF OBJECT_ID('[raw_css2].[products]', 'U') IS NOT NULL DROP TABLE [raw_css2].[products];
        -- raw_css2.categories_products is dacpac-seeded; never drop it.
        IF OBJECT_ID('[raw_css2].[ItemGroupings_T]', 'U') IS NOT NULL DROP TABLE [raw_css2].[ItemGroupings_T];
        IF OBJECT_ID('[raw_css2].[ProductOptions_T]', 'U') IS NOT NULL DROP TABLE [raw_css2].[ProductOptions_T];
        IF OBJECT_ID('[raw_css2].[SortByRelevance]', 'U') IS NOT NULL DROP TABLE [raw_css2].[SortByRelevance];

        PRINT CONCAT(@proc_name, ' - Dropped raw_css2 tables');

        -- All incremental tables now full-reload (DROP + autoCreate handles schema drift).
        IF OBJECT_ID('[raw_ccdata].[InvoiceHeader]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[InvoiceHeader];
        IF OBJECT_ID('[raw_ccdata].[SundryHeader]', 'U') IS NOT NULL DROP TABLE [raw_ccdata].[SundryHeader];

        PRINT CONCAT(@proc_name, ' - Dropped incremental header tables');

        -- Excluded:
        --   raw_ccdata.CategoryMap      (not loaded from ADF)
        --   raw_inventory.Inventory     (daily snapshot, keeps history)
        --   raw_365.*, raw_google.*     (separate pipelines)

        PRINT CONCAT(
            @proc_name,
            ' - Completed at ',
            CONVERT(VARCHAR(30), GETDATE(), 120)
        );

    END TRY BEGIN CATCH
        DECLARE @error_message NVARCHAR(4000) = CONCAT(
            @proc_name,
            ' failed: ',
            ERROR_MESSAGE()
        );

        THROW 50000, @error_message, 1;

    END CATCH
END
