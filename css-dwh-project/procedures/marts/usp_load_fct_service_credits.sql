CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_service_credits];
[marts].[usp_load_fct_service_credits]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_fct_service_credits';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_affected AS INT = 0;
    DECLARE @last_refresh AS DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @ForceFullLoad = 1
            BEGIN
                -- Override mode: empty the table and pull everything
                TRUNCATE TABLE [marts].[fct_service_credits];
                SET @last_refresh = '1900-01-01';
            END
        ELSE
            BEGIN
                -- Standard incremental mode: Ask the target table exactly where it left off, minus a 1-hour buffer
                SELECT @last_refresh = COALESCE (DATEADD(hour, -1, MAX(row_modified_datetime)), '1900-01-01')
                FROM   [marts].[fct_service_credits];
            END
        MERGE INTO [marts].[fct_service_credits]
         AS tgt
        USING (SELECT transaction_key,
                      credit_date,
                      credit_time,
                      order_date,
                      customer_code,
                      salesperson_employee_key,
                      engineer_key,
                      creditor_key,
                      approver_key,
                      invoice_connection_number,
                      order_number,
                      web_order_id,
                      row_modified_datetime,
                      product_key,
                      description,
                      line_sequence_number,
                      quantity,
                      price_before_discount,
                      price,
                      vat_amount,
                      cost,
                      order_channel,
                      service_type_key
               FROM   [marts].[vw_fct_service_credits]
               WHERE  row_modified_datetime >= @last_refresh) AS src ON tgt.transaction_key = src.transaction_key -- grain: one row per invoice line
                                                                        AND tgt.line_sequence_number = src.line_sequence_number
        WHEN MATCHED THEN UPDATE 
        SET credit_date               = src.credit_date,
            credit_time               = src.credit_time,
            order_date                = src.order_date,
            customer_code             = src.customer_code,
            salesperson_employee_key  = src.salesperson_employee_key,
            engineer_key              = src.engineer_key,
            creditor_key              = src.creditor_key,
            approver_key              = src.approver_key,
            invoice_connection_number = src.invoice_connection_number,
            order_number              = src.order_number,
            web_order_id              = src.web_order_id,
            row_modified_datetime     = src.row_modified_datetime,
            product_key               = src.product_key,
            description               = src.description,
            quantity                  = src.quantity,
            price_before_discount     = src.price_before_discount,
            price                     = src.price,
            vat_amount                = src.vat_amount,
            cost                      = src.cost,
            order_channel             = src.order_channel,
            service_type_key          = src.service_type_key
        WHEN NOT MATCHED BY TARGET THEN INSERT (
            transaction_key,
            credit_date,
            credit_time,
            order_date,
            customer_code,
            salesperson_employee_key,
            engineer_key,
            creditor_key,
            approver_key,
            invoice_connection_number,
            order_number,
            web_order_id,
            row_modified_datetime,
            product_key,
            description,
            line_sequence_number,
            quantity,
            price_before_discount,
            price,
            vat_amount,
            cost,
            order_channel,
            service_type_key
        ) VALUES (src.transaction_key, src.credit_date, src.credit_time, src.order_date, src.customer_code, src.salesperson_employee_key, src.engineer_key, src.creditor_key, src.approver_key, src.invoice_connection_number, src.order_number, src.web_order_id, src.row_modified_datetime, src.product_key, src.description, src.line_sequence_number, src.quantity, src.price_before_discount, src.price, src.vat_amount, src.cost, src.order_channel, src.service_type_key);
        SET @rows_affected = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- Truncate wipes the histogram; force a fresh scan so the optimizer isn't left with stale/empty stats
        IF @ForceFullLoad = 1
            BEGIN
                UPDATE STATISTICS [marts].[fct_service_credits]
                    WITH FULLSCAN;
                EXECUTE (N'EXEC sp_recompile N''[marts].[fct_service_credits]'';');
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