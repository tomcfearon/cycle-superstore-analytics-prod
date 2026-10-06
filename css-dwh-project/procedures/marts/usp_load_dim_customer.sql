CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_dim_customer];
[marts].[usp_load_dim_customer]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_dim_customer';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_affected AS INT = 0;
    DECLARE @last_refresh AS DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @ForceFullLoad = 1
            BEGIN
                -- Override mode: empty the table and pull everything
                TRUNCATE TABLE [marts].[dim_customer];
                SET @last_refresh = '1900-01-01';
            END
        ELSE
            BEGIN
                -- Standard incremental mode: Ask the target table exactly where it left off, minus a 1-hour buffer
                SELECT @last_refresh = COALESCE (DATEADD(hour, -1, MAX(row_modified_datetime)), '1900-01-01')
                FROM   [marts].[dim_customer];
            END
        MERGE INTO [marts].[dim_customer]
         AS tgt
        USING (SELECT customer_code,
                      customer_name,
                      customer_type,
                      price_band,
                      company,
                      is_on_stop,
                      is_archived,
                      is_confirmed_female,
                      credit_terms,
                      credit_limit,
                      credit_balance,
                      account_opened_date,
                      row_modified_datetime,
                      last_in_store_date,
                      email,
                      web_customer_id,
                      web_cp_connection,
                      web_first_name,
                      web_last_name,
                      web_company,
                      web_phone,
                      web_address_line_1,
                      web_address_line_2,
                      web_postal_code,
                      web_state_code,
                      web_state,
                      web_city,
                      web_country_code,
                      web_customer_type,
                      web_created_at,
                      retail_trade
               FROM   [marts].[vw_dim_customer]
               WHERE  row_modified_datetime >= @last_refresh) AS src ON tgt.customer_code = src.customer_code -- grain: one row per customer
        WHEN MATCHED THEN UPDATE 
        SET customer_name         = src.customer_name,
            customer_type         = src.customer_type,
            price_band            = src.price_band,
            company               = src.company,
            is_on_stop            = src.is_on_stop,
            is_archived           = src.is_archived,
            is_confirmed_female   = src.is_confirmed_female,
            credit_terms          = src.credit_terms,
            credit_limit          = src.credit_limit,
            credit_balance        = src.credit_balance,
            account_opened_date   = src.account_opened_date,
            row_modified_datetime = src.row_modified_datetime,
            last_in_store_date    = src.last_in_store_date,
            email                 = src.email,
            web_customer_id       = src.web_customer_id,
            web_cp_connection     = src.web_cp_connection,
            web_first_name        = src.web_first_name,
            web_last_name         = src.web_last_name,
            web_company           = src.web_company,
            web_phone             = src.web_phone,
            web_address_line_1    = src.web_address_line_1,
            web_address_line_2    = src.web_address_line_2,
            web_postal_code       = src.web_postal_code,
            web_state_code        = src.web_state_code,
            web_state             = src.web_state,
            web_city              = src.web_city,
            web_country_code      = src.web_country_code,
            web_customer_type     = src.web_customer_type,
            web_created_at        = src.web_created_at,
            retail_trade          = src.retail_trade
        WHEN NOT MATCHED BY TARGET THEN INSERT (
            customer_code,
            customer_name,
            customer_type,
            price_band,
            company,
            is_on_stop,
            is_archived,
            is_confirmed_female,
            credit_terms,
            credit_limit,
            credit_balance,
            account_opened_date,
            row_modified_datetime,
            last_in_store_date,
            email,
            web_customer_id,
            web_cp_connection,
            web_first_name,
            web_last_name,
            web_company,
            web_phone,
            web_address_line_1,
            web_address_line_2,
            web_postal_code,
            web_state_code,
            web_state,
            web_city,
            web_country_code,
            web_customer_type,
            web_created_at,
            retail_trade
        ) VALUES (src.customer_code, src.customer_name, src.customer_type, src.price_band, src.company, src.is_on_stop, src.is_archived, src.is_confirmed_female, src.credit_terms, src.credit_limit, src.credit_balance, src.account_opened_date, src.row_modified_datetime, src.last_in_store_date, src.email, src.web_customer_id, src.web_cp_connection, src.web_first_name, src.web_last_name, src.web_company, src.web_phone, src.web_address_line_1, src.web_address_line_2, src.web_postal_code, src.web_state_code, src.web_state, src.web_city, src.web_country_code, src.web_customer_type, src.web_created_at, src.retail_trade);
        SET @rows_affected = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- Truncate wipes the histogram; force a fresh scan so the optimizer isn't left with stale/empty stats
        IF @ForceFullLoad = 1
            BEGIN
                UPDATE STATISTICS [marts].[dim_customer]
                    WITH FULLSCAN;
                EXECUTE (N'EXEC sp_recompile N''[marts].[dim_customer]'';');
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