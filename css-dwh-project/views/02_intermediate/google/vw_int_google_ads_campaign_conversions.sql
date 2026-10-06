-- Purpose: Integrates campaign conversion stats with campaign labels to produce
--          daily conversion aggregates per campaign and conversion action category,
--          enriched with funnel classification (Bottom Funnel / Medium Funnel).
--
-- Aggregation: Sums conversions and conversion value by campaign, date, and
--              conversion action category — removing ad network type, event type,
--              and other granular segments from the raw data.
--
-- Funnel type: Derived from campaign labels. If a campaign has both a
--              "Bottom Funnel" and "Medium Funnel" label, Medium Funnel wins.
CREATE
-- OR ALTER
VIEW [int].[google_ads_campaign_conversions] AS
    WITH campaign_names AS (
        SELECT
            cl.[campaign_id],
            cl.[campaign_name],
            ROW_NUMBER() OVER (
                PARTITION BY cl.[campaign_id]
                ORDER BY cl.[_DATA_DATE] DESC
            ) AS rn
        FROM
            [stg].[google_ads_campaign_label] AS cl
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
        FROM
            [stg].[google_ads_campaign_label] AS cl
        WHERE
            LOWER(cl.[label_name]) IN ('bottom funnel', 'medium funnel')
    )

    SELECT
        cn.[campaign_name],
        cs.[campaign_id],
        cs.[segments_conversion_action_category] AS conversion_action_category,
        CAST(cs.[_DATA_DATE] AS date)            AS conversion_date,
        SUM(cs.[metrics_conversions])             AS total_conversions,
        SUM(cs.[metrics_conversions_value])       AS total_conversions_value,
        MAX(fl.[label_name])                           AS funnel_type
    FROM
        [stg].[google_ads_campaign_conversion_stats] AS cs
        LEFT JOIN campaign_names AS cn
            ON cs.[campaign_id] = cn.[campaign_id]
            AND cn.rn = 1
        LEFT JOIN funnel_labels AS fl
            ON cs.[campaign_id] = fl.[campaign_id]
            AND fl.rn = 1
    GROUP BY
        cn.[campaign_name],
        cs.[campaign_id],
        cs.[segments_conversion_action_category],
        CAST(cs.[_DATA_DATE] AS date)
-- ORDER BY conversion_date DESC;
