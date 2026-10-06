CREATE
-- OR ALTER
-- Quick-run entry point for manual execution from this file.
-- EXEC [meta].[usp_log_refresh];
PROCEDURE [meta].[usp_log_refresh]
    @table_name VARCHAR(200)
    , @refresh_time_utc DATETIME2(7) = NULL -- optional override for backfills and replays
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @table_name_trimmed VARCHAR(200) = LOWER(LTRIM(RTRIM(@table_name)));
    DECLARE @dot_pos INT = CHARINDEX('.', @table_name_trimmed);
    DECLARE @layer_name VARCHAR(50);
    DECLARE @effective_refresh_time_utc DATETIME2(7) = COALESCE(@refresh_time_utc, SYSUTCDATETIME()); -- default to now

    IF @table_name_trimmed IS NULL OR @table_name_trimmed = ''
    BEGIN
        RAISERROR('meta.usp_log_refresh requires @table_name.', 16, 1); -- reject missing input
        RETURN;
    END;

    IF @dot_pos > 1
    BEGIN
        SET @layer_name = LEFT(@table_name_trimmed, @dot_pos - 1);
    END
    ELSE
    BEGIN
        -- For ADF/raw loads where callers may pass only table name.
        SET @layer_name = 'raw';
    END;

    UPDATE [meta].[refresh_metadata] -- update existing refresh row when present
    SET
        refresh = refresh + 1,
        layer_name = @layer_name,
        last_refresh_utc = @effective_refresh_time_utc
    WHERE table_name = @table_name_trimmed;

    IF @@ROWCOUNT = 0
    BEGIN
        INSERT [meta].[refresh_metadata]
            (table_name, layer_name, refresh, last_refresh_utc)
        VALUES
            (@table_name_trimmed, @layer_name, 1, @effective_refresh_time_utc);
    END;
END;
