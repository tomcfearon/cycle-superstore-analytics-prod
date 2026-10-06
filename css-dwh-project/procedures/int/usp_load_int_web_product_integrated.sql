CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [int].[usp_load_web_product_integrated];
[int].[usp_load_web_product_integrated]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'int.usp_load_web_stock_integrated';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_inserted AS INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        TRUNCATE TABLE [int].[web_product_integrated];
        INSERT INTO [int].[web_product_integrated] (
            is_bike_product,
            stock_code,
            web_product_id,
            web_parent_product_id,
            web_title,
            web_price,
            web_list_price,
            extended_warehouse_quantity,
            web_is_active,
            web_is_list_hidden,
            color,
            [size],
            product_options_last_refreshed,
            brand_name,
            web_link,
            main_image_link,
            additional_image_links,
            web_category_id,
            product_type,
            gpc_path,
            web_html_details,
            web_gender,
            web_item_material,
            item_groupings_last_refreshed,
            web_item_group_title,
            variant_descriptor
        )
        SELECT is_bike_product,
               stock_code,
               web_product_id,
               web_parent_product_id,
               web_title,
               web_price,
               web_list_price,
               extended_warehouse_quantity,
               web_is_active,
               web_is_list_hidden,
               color,
               [size],
               product_options_last_refreshed,
               brand_name,
               web_link,
               main_image_link,
               additional_image_links,
               web_category_id,
               product_type,
               gpc_path,
               web_html_details,
               web_gender,
               web_item_material,
               item_groupings_last_refreshed,
               web_item_group_title,
               variant_descriptor
        FROM   [int].[vw_web_product_integrated];
        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        EXECUTE [meta].[usp_log_refresh] @table_name = 'int.web_product_integrated';
        PRINT CONCAT(@proc_name, ' succeeded. Rows inserted: ', @rows_inserted, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END


-- SELECT TOP 100 * from [int].[web_product_integrated]
-- WHERE variant_descriptor IS NOT NULL