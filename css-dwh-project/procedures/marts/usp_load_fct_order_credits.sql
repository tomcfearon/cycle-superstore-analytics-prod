CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_order_credits];
[marts].[usp_load_fct_order_credits]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_fct_order_credits';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_affected AS INT = 0;
    DECLARE @rows_deleted AS INT = 0;
    DECLARE @last_refresh AS DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @ForceFullLoad = 1
            BEGIN
                -- Override mode: empty the table and pull everything
                TRUNCATE TABLE [marts].[fct_order_credits];
                SET @last_refresh = '1900-01-01';
            END
        ELSE
            BEGIN
                -- Standard incremental mode: Ask the target table exactly where it left off, minus a 1-hour buffer
                SELECT @last_refresh = COALESCE (DATEADD(hour, -1, MAX(row_modified_datetime)), '1900-01-01')
                FROM   [marts].[fct_order_credits];
            END
        -- Prune rows that no longer qualify as order credits (e.g. reclassified to a service credit once a
        -- repair invoice later linked up). These never change row_modified_datetime, so the incremental MERGE
        -- below would otherwise never revisit or remove them; this anti-join is checked against the full view.
        DELETE tgt
        FROM   [marts].[fct_order_credits] AS tgt
        WHERE  NOT EXISTS (SELECT 1
                           FROM   [marts].[vw_fct_order_credits] AS src
                           WHERE  src.transaction_key = tgt.transaction_key
                                  AND src.line_sequence_number = tgt.line_sequence_number);
        SET @rows_deleted = @@ROWCOUNT;
        MERGE INTO [marts].[fct_order_credits]
         AS tgt
        USING (SELECT transaction_key,
                      credit_date,
                      customer_code,
                      employee_key,
                      creditor_key,
                      product_key,
                      quantity,
                      price,
                      vat_amount,
                      cost,
                      price_before_discount,
                      approver_key,
                      order_date,
                      order_time,
                      is_dispatched,
                      invoice_connection_number,
                      web_order_id,
                      line_sequence_number,
                      description,
                      row_modified_datetime,
                      order_channel,
                      collection_employee_key
               FROM   [marts].[vw_fct_order_credits]
               WHERE  row_modified_datetime >= @last_refresh) AS src ON tgt.transaction_key = src.transaction_key -- grain: one row per credit line
                                                                        AND tgt.line_sequence_number = src.line_sequence_number
        WHEN MATCHED THEN UPDATE 
        SET credit_date               = src.credit_date,
            customer_code             = src.customer_code,
            employee_key              = src.employee_key,
            creditor_key              = src.creditor_key,
            product_key               = src.product_key,
            quantity                  = src.quantity,
            price                     = src.price,
            vat_amount                = src.vat_amount,
            cost                      = src.cost,
            price_before_discount     = src.price_before_discount,
            approver_key              = src.approver_key,
            order_date                = src.order_date,
            order_time                = src.order_time,
            is_dispatched             = src.is_dispatched,
            invoice_connection_number = src.invoice_connection_number,
            web_order_id              = src.web_order_id,
            description               = src.description,
            row_modified_datetime     = src.row_modified_datetime,
            order_channel             = src.order_channel,
            collection_employee_key   = src.collection_employee_key
        WHEN NOT MATCHED BY TARGET THEN INSERT (
            transaction_key,
            credit_date,
            customer_code,
            employee_key,
            creditor_key,
            product_key,
            quantity,
            price,
            vat_amount,
            cost,
            price_before_discount,
            approver_key,
            order_date,
            order_time,
            is_dispatched,
            invoice_connection_number,
            web_order_id,
            line_sequence_number,
            description,
            row_modified_datetime,
            order_channel,
            collection_employee_key
        ) VALUES (src.transaction_key, src.credit_date, src.customer_code, src.employee_key, src.creditor_key, src.product_key, src.quantity, src.price, src.vat_amount, src.cost, src.price_before_discount, src.approver_key, src.order_date, src.order_time, src.is_dispatched, src.invoice_connection_number, src.web_order_id, src.line_sequence_number, src.description, src.row_modified_datetime, src.order_channel, src.collection_employee_key);
        SET @rows_affected = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- Truncate wipes the histogram; force a fresh scan so the optimizer isn't left with stale/empty stats
        IF @ForceFullLoad = 1
            BEGIN
                UPDATE STATISTICS [marts].[fct_order_credits]
                    WITH FULLSCAN;
                EXECUTE (N'EXEC sp_recompile N''[marts].[fct_order_credits]'';');
            END
        PRINT CONCAT(@proc_name, ' succeeded. Rows merged: ', @rows_affected, '. Rows pruned (reclassified/removed): ', @rows_deleted, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END