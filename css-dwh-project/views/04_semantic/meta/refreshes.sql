CREATE
-- OR ALTER
VIEW [dbo].[98 - Refreshes] AS
SELECT
    rm.table_name AS "Table Name",
    rm.layer_name AS "Layer Name",
    rm.refresh AS "Refresh",
    CAST(
        CASE
            -- Reported CCData freshness is clamped to the effective source-vs-warehouse cutoff.
            WHEN rm.layer_name = 'raw_ccdata'
             AND rm.table_name <> 'raw_ccdata.raw_inventory'
            THEN er.effective_last_refresh_utc
            ELSE rm.last_refresh_utc
        END
    AS DATE) AS "Last Refresh Date",
    CASE
        -- Keep semantic refresh cards aligned with the date dimension's current-period logic.
        WHEN rm.layer_name = 'raw_ccdata'
         AND rm.table_name <> 'raw_ccdata.raw_inventory'
        THEN er.effective_last_refresh_utc
        ELSE rm.last_refresh_utc
    END AS "Last Refresh UTC"
FROM [meta].[refresh_metadata] AS rm
CROSS JOIN [dbo].[vw_ccdata_effective_refresh] AS er;
