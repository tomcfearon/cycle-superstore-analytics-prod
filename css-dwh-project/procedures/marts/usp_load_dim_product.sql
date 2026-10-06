CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_dim_product];
[marts].[usp_load_dim_product]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_dim_product';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_affected AS INT = 0;
    DECLARE @last_refresh AS DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @ForceFullLoad = 1
            BEGIN
                -- Override mode: empty the table and pull everything
                TRUNCATE TABLE [marts].[dim_product];
                SET @last_refresh = '1900-01-01';
            END
        ELSE
            BEGIN
                -- Standard incremental mode: Ask the target table exactly where it left off, minus a 1-hour buffer
                SELECT @last_refresh = COALESCE (DATEADD(hour, -1, MAX(row_modified_datetime)), '1900-01-01')
                FROM   [marts].[dim_product];
            END
        MERGE INTO [marts].[dim_product]
         AS tgt
        USING (SELECT product_key,
                      stock_code,
                      brand,
                      erp_brand,
                      title,
                      product_group_title,
                      category,
                      subcategory,
                      retail_price,
                      cost_price,
                      average_cost_price,
                      selling_price_1,
                      selling_price_2,
                      selling_price_3,
                      selling_price_4,
                      selling_price_5,
                      selling_price_6,
                      selling_price_7,
                      sale_price,
                      trade_sale_price,
                      is_active,
                      is_on_web,
                      is_discontinued,
                      web_is_active,
                      web_is_list_hidden,
                      color,
                      [size],
                      product_options_last_refreshed,
                      item_groupings_last_refreshed,
                      store_db_title,
                      web_link,
                      main_image_link,
                      additional_image_links,
                      web_category_path,
                      google_category,
                      html_details,
                      [gender],
                      item_material,
                      product_id,
                      product_group_id,
                      web_price,
                      web_list_price,
                      extended_warehouse_quantity,
                      web_is_bike_product,
                      model_year,
                      is_new,
                      stock_type,
                      bike_sundry,
                      bike_category,
                      electric_manual_sundry,
                      main_bike_type,
                      category_type,
                      subcategory_type,
                      is_distribution,
                      main_sundry_repairs,
                      variant_descriptor,
                      benchmark_price,
                      suggested_price,
                      clean_product_name,
                      row_modified_datetime
               FROM   [marts].[vw_dim_product]
               WHERE  row_modified_datetime >= @last_refresh) AS src ON tgt.product_key = src.product_key -- grain: one row per product
        WHEN MATCHED THEN UPDATE 
        SET stock_code                     = src.stock_code,
            brand                          = src.brand,
            erp_brand                      = src.erp_brand,
            title                          = src.title,
            product_group_title            = src.product_group_title,
            category                       = src.category,
            subcategory                    = src.subcategory,
            retail_price                   = src.retail_price,
            cost_price                     = src.cost_price,
            average_cost_price             = src.average_cost_price,
            selling_price_1                = src.selling_price_1,
            selling_price_2                = src.selling_price_2,
            selling_price_3                = src.selling_price_3,
            selling_price_4                = src.selling_price_4,
            selling_price_5                = src.selling_price_5,
            selling_price_6                = src.selling_price_6,
            selling_price_7                = src.selling_price_7,
            sale_price                     = src.sale_price,
            trade_sale_price               = src.trade_sale_price,
            is_active                      = src.is_active,
            is_on_web                      = src.is_on_web,
            is_discontinued                = src.is_discontinued,
            web_is_active                  = src.web_is_active,
            web_is_list_hidden             = src.web_is_list_hidden,
            color                          = src.color,
            [size]                         = src.[size],
            product_options_last_refreshed = src.product_options_last_refreshed,
            item_groupings_last_refreshed  = src.item_groupings_last_refreshed,
            store_db_title                 = src.store_db_title,
            web_link                       = src.web_link,
            main_image_link                = src.main_image_link,
            additional_image_links         = src.additional_image_links,
            web_category_path              = src.web_category_path,
            google_category                = src.google_category,
            html_details                   = src.html_details,
            [gender]                       = src.[gender],
            item_material                  = src.item_material,
            product_id                     = src.product_id,
            product_group_id               = src.product_group_id,
            web_price                      = src.web_price,
            web_list_price                 = src.web_list_price,
            extended_warehouse_quantity    = src.extended_warehouse_quantity,
            web_is_bike_product            = src.web_is_bike_product,
            model_year                     = src.model_year,
            is_new                         = src.is_new,
            stock_type                     = src.stock_type,
            bike_sundry                    = src.bike_sundry,
            bike_category                  = src.bike_category,
            electric_manual_sundry         = src.electric_manual_sundry,
            main_bike_type                 = src.main_bike_type,
            category_type                  = src.category_type,
            subcategory_type               = src.subcategory_type,
            is_distribution                = src.is_distribution,
            main_sundry_repairs            = src.main_sundry_repairs,
            variant_descriptor             = src.variant_descriptor,
            benchmark_price                = src.benchmark_price,
            suggested_price                = src.suggested_price,
            clean_product_name             = src.clean_product_name,
            row_modified_datetime          = src.row_modified_datetime
        WHEN NOT MATCHED BY TARGET THEN INSERT (
            product_key,
            stock_code,
            brand,
            erp_brand,
            title,
            product_group_title,
            category,
            subcategory,
            retail_price,
            cost_price,
            average_cost_price,
            selling_price_1,
            selling_price_2,
            selling_price_3,
            selling_price_4,
            selling_price_5,
            selling_price_6,
            selling_price_7,
            sale_price,
            trade_sale_price,
            is_active,
            is_on_web,
            is_discontinued,
            web_is_active,
            web_is_list_hidden,
            color,
            [size],
            product_options_last_refreshed,
            item_groupings_last_refreshed,
            store_db_title,
            web_link,
            main_image_link,
            additional_image_links,
            web_category_path,
            google_category,
            html_details,
            [gender],
            item_material,
            product_id,
            product_group_id,
            web_price,
            web_list_price,
            extended_warehouse_quantity,
            web_is_bike_product,
            model_year,
            is_new,
            stock_type,
            bike_sundry,
            bike_category,
            electric_manual_sundry,
            main_bike_type,
            category_type,
            subcategory_type,
            is_distribution,
            main_sundry_repairs,
            variant_descriptor,
            benchmark_price,
            suggested_price,
            clean_product_name,
            row_modified_datetime
        ) VALUES (src.product_key, src.stock_code, src.brand, src.erp_brand, src.title, src.product_group_title, src.category, src.subcategory, src.retail_price, src.cost_price, src.average_cost_price, src.selling_price_1, src.selling_price_2, src.selling_price_3, src.selling_price_4, src.selling_price_5, src.selling_price_6, src.selling_price_7, src.sale_price, src.trade_sale_price, src.is_active, src.is_on_web, src.is_discontinued, src.web_is_active, src.web_is_list_hidden, src.color, src.[size], src.product_options_last_refreshed, src.item_groupings_last_refreshed, src.store_db_title, src.web_link, src.main_image_link, src.additional_image_links, src.web_category_path, src.google_category, src.html_details, src.[gender], src.item_material, src.product_id, src.product_group_id, src.web_price, src.web_list_price, src.extended_warehouse_quantity, src.web_is_bike_product, src.model_year, src.is_new, src.stock_type, src.bike_sundry, src.bike_category, src.electric_manual_sundry, src.main_bike_type, src.category_type, src.subcategory_type, src.is_distribution, src.main_sundry_repairs, src.variant_descriptor, src.benchmark_price, src.suggested_price, src.clean_product_name, src.row_modified_datetime);
        SET @rows_affected = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- Truncate wipes the histogram; force a fresh scan so the optimizer isn't left with stale/empty stats
        IF @ForceFullLoad = 1
            BEGIN
                UPDATE STATISTICS [marts].[dim_product]
                    WITH FULLSCAN;
                EXECUTE (N'EXEC sp_recompile N''[marts].[dim_product]'';');
            END
        PRINT CONCAT(@proc_name, ' succeeded. Rows merged: ', @rows_affected, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END