-- Purpose: Aggregate Google Ads campaign performance to one row per campaign per day
--          so spend and traffic metrics stay additive when joined to reporting.
CREATE
-- OR ALTER
VIEW [int].[vw_int_google_ads_campaign_daily_stats] AS
    WITH campaign_names AS (
        SELECT
            cl.[campaign_id],
            cl.[campaign_name],
            ROW_NUMBER() OVER (
                PARTITION BY cl.[campaign_id]
                ORDER BY cl.[_DATA_DATE] DESC
            ) AS rn
        FROM [stg].[google_ads_campaign_label] AS cl
    ),

    funnel_labels AS (
        SELECT
            cl.[campaign_id],
            cl.[label_name],
            ROW_NUMBER() OVER (
                PARTITION BY cl.[campaign_id]
                ORDER BY
                    CASE
                        WHEN LOWER(cl.[label_name]) = 'medium funnel' THEN 1
                        WHEN LOWER(cl.[label_name]) = 'bottom funnel' THEN 2
                    END
            ) AS rn
        FROM [stg].[google_ads_campaign_label] AS cl
        WHERE LOWER(cl.[label_name]) IN ('bottom funnel', 'medium funnel')
    )

    SELECT
        cn.[campaign_name],
        gs.[campaign_id],
        CAST(gs.[_DATA_DATE] AS date) AS stats_date,
        SUM(COALESCE(gs.[metrics_clicks], 0)) AS total_clicks,
        SUM(COALESCE(gs.[metrics_impressions], 0)) AS total_impressions,
        -- Google Ads stores cost in micros, so convert once here for report-facing facts.
        CAST(SUM(COALESCE(CAST(gs.[metrics_cost_micros] AS decimal(19, 6)), 0)) / 1000000.0 AS decimal(19, 6)) AS total_cost,
        SUM(COALESCE(gs.[metrics_interactions], 0)) AS total_interactions,
        MAX(fl.[label_name]) AS funnel_type
    FROM [stg].[google_ads_campaign_stats] AS gs
        LEFT JOIN campaign_names AS cn
            ON gs.[campaign_id] = cn.[campaign_id]
            AND cn.rn = 1
        LEFT JOIN funnel_labels AS fl
            ON gs.[campaign_id] = fl.[campaign_id]
            AND fl.rn = 1
    GROUP BY
        cn.[campaign_name],
        gs.[campaign_id],
        CAST(gs.[_DATA_DATE] AS date)
GO
