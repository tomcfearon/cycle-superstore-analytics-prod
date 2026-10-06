CREATE PROCEDURE -- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [marts].[usp_load_dim_transaction];
[marts].[usp_load_dim_transaction]
@ForceFullLoad BIT=0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @proc_name AS sysname = 'marts.usp_load_dim_transaction';
    DECLARE @started_at AS DATETIME2 (3) = SYSDATETIME();
    DECLARE @rows_affected AS INT = 0;
    DECLARE @last_refresh AS DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @ForceFullLoad = 1
            BEGIN
                -- Override mode: empty the table and pull everything
                TRUNCATE TABLE [marts].[dim_transaction];
                SET @last_refresh = '1900-01-01';
            END
        ELSE
            BEGIN
                -- Standard incremental mode: Ask the target table exactly where it left off, minus a 1-hour buffer
                SELECT @last_refresh = COALESCE (DATEADD(hour, -1, MAX(row_modified_datetime)), '1900-01-01')
                FROM   [marts].[dim_transaction];
            END
        MERGE INTO [marts].[dim_transaction]
         AS tgt
        USING (SELECT transaction_key,
                      document_number,
                      document_type,
                      internal_note,
                      row_modified_datetime
               FROM   [marts].[vw_dim_transaction]
               -- Sales Orders has no source watermark (row_modified_datetime IS NULL); always re-include it (~500 rows, cheap)
               WHERE  row_modified_datetime >= @last_refresh
                      OR row_modified_datetime IS NULL) AS src ON tgt.transaction_key = src.transaction_key -- grain: one row per document
        WHEN MATCHED THEN UPDATE 
        SET document_number       = src.document_number,
            document_type         = src.document_type,
            internal_note         = src.internal_note,
            row_modified_datetime = src.row_modified_datetime
        WHEN NOT MATCHED BY TARGET THEN INSERT (
            transaction_key,
            document_number,
            document_type,
            internal_note,
            row_modified_datetime
        ) VALUES (src.transaction_key, src.document_number, src.document_type, src.internal_note, src.row_modified_datetime);
        SET @rows_affected = @@ROWCOUNT;
        COMMIT TRANSACTION;
        -- Truncate wipes the histogram; force a fresh scan so the optimizer isn't left with stale/empty stats
        IF @ForceFullLoad = 1
            BEGIN
                UPDATE STATISTICS [marts].[dim_transaction]
                    WITH FULLSCAN;
                EXECUTE (N'EXEC sp_recompile N''[marts].[dim_transaction]'';');
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