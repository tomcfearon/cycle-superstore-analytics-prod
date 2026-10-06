CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_fct_xero_bank_transaction_debits];
[marts].[usp_load_fct_xero_bank_transaction_debits]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_fct_xero_bank_transaction_debits';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_inserted AS INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        TRUNCATE TABLE [marts].[fct_xero_bank_transaction_debits];
        INSERT INTO [marts].[fct_xero_bank_transaction_debits] (
            bank_transaction_id,
            transaction_date,
            contact_name,
            contact_type,
            account_code,
            amount,
            tax_amount,
            [description],
            currency_code,
            updated_date_utc
        )
        SELECT bank_transaction_id,
               transaction_date,
               contact_name,
               contact_type,
               account_code,
               amount,
               tax_amount,
               [description],
               currency_code,
               updated_date_utc
        FROM   [marts].[vw_fct_xero_bank_transaction_debits];
        SET @rows_inserted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        MERGE INTO [meta].[refresh_metadata]
         AS tgt
        USING (SELECT N'marts.fct_xero_bank_transaction_debits' AS table_name) AS src ON tgt.table_name = src.table_name
        WHEN MATCHED THEN UPDATE 
        SET refresh          = tgt.refresh + 1,
            last_refresh_utc = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN INSERT (
            table_name,
            layer_name,
            refresh,
            last_refresh_utc
        ) VALUES (src.table_name, N'marts', 1, SYSUTCDATETIME());
        PRINT CONCAT(@proc_name, ' succeeded. Rows inserted: ', @rows_inserted, '. Duration (ms): ', DATEDIFF(ms, @started_at, SYSDATETIME()));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @error_message AS NVARCHAR (4000) = CONCAT(@proc_name, ' failed: ', ERROR_MESSAGE());
        THROW 50000, @error_message, 1;
    END CATCH
END
