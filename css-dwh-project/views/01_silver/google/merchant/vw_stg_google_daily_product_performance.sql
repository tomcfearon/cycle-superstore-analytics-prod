-- Source: raw_google.vw_daily_product_performance — pre-aggregated daily product performance
--         loaded via ADF from BigQuery (Google Merchant Center performance report).
-- Purpose: Renames offer_id to product_id for consistency with warehouse conventions.
CREATE
-- OR ALTER
VIEW [stg].[google_daily_product_performance] AS
SELECT
    t.[partition_date]     AS [performance_date],
    t.[offer_id]           AS [product_id],
    t.[destination],
    t.[total_impressions],
    t.[total_clicks]
FROM
    [raw_google].[vw_daily_product_performance] AS t
WHERE
    t.[partition_date]
>= '2025-11-01' --remove old offer id before new mc pipeline was added
