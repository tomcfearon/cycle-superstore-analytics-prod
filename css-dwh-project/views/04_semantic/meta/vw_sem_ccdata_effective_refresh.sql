CREATE
-- OR ALTER
VIEW [dbo].[vw_ccdata_effective_refresh] AS

/*
    Effective CCData refresh for user-facing freshness flags.

    Source-side raw_ccdata can land ahead of the warehouse fact reloads.
    For semantic freshness logic, clamp CCData to the latest point that is
    available in both places: the minimum of source refresh and warehouse
    fact refresh. Inventory, Google, and Exchange data refresh on separate
    schedules and must not suppress CCData date flags.
*/

WITH source_refresh AS (
    SELECT
        MAX(last_refresh_utc) AS source_last_refresh_utc
    FROM [meta].[refresh_metadata]
    WHERE [layer_name] = 'raw_ccdata'
      AND [table_name] <> 'raw_ccdata.raw_inventory'
),
warehouse_refresh AS (
    SELECT
        MAX(last_refresh_utc) AS warehouse_last_refresh_utc
    FROM [meta].[refresh_metadata]
    WHERE [layer_name] = 'marts'
      AND [table_name] LIKE 'marts.fct_%'
      AND [table_name] NOT IN (
            'marts.fct_exchange_emails_with_customer',
            'marts.fct_google_ads_campaign_conversions',
            'marts.fct_google_ads_campaign_daily_stats',
            'marts.fct_google_daily_product_performance',
            'marts.fct_inventory'
      )
)
SELECT
    s.source_last_refresh_utc,
    w.warehouse_last_refresh_utc,
    CASE
        -- Fall back to the available side if one side is missing during setup/backfill.
        WHEN s.source_last_refresh_utc IS NULL THEN w.warehouse_last_refresh_utc
        WHEN w.warehouse_last_refresh_utc IS NULL THEN s.source_last_refresh_utc
        WHEN s.source_last_refresh_utc <= w.warehouse_last_refresh_utc THEN s.source_last_refresh_utc
        ELSE w.warehouse_last_refresh_utc
    END AS effective_last_refresh_utc
FROM source_refresh AS s
CROSS JOIN warehouse_refresh AS w;
