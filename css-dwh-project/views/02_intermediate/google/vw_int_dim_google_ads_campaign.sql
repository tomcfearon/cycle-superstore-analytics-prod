-- Purpose: Expose one latest row per Google Ads campaign with its current name
--          and prioritized funnel classification for downstream dimension use.
CREATE
-- OR ALTER
VIEW [int].[vw_int_dim_google_ads_campaign] AS
    WITH campaign_ids AS (
        -- Base campaign set stays at one row per campaign_id before attribute joins.
        SELECT DISTINCT
            cl.[campaign_id]
        FROM [stg].[google_ads_campaign_label] AS cl
    ),

    campaign_names AS (
        -- Latest snapshot wins for campaign naming.
        SELECT
            cl.[campaign_id],
            cl.[campaign_name],
            ROW_NUMBER() OVER (
                PARTITION BY cl.[campaign_id]
                ORDER BY cl.[_DATA_DATE] DESC, cl.[campaign_name] ASC
            ) AS rn
        FROM [stg].[google_ads_campaign_label] AS cl
    ),

    funnel_labels AS (
        -- Medium Funnel outranks Bottom Funnel when both labels exist.
        SELECT
            cl.[campaign_id],
            cl.[label_name],
            ROW_NUMBER() OVER (
                PARTITION BY cl.[campaign_id]
                ORDER BY
                    CASE
                        WHEN LOWER(cl.[label_name]) = 'medium funnel' THEN 1
                        WHEN LOWER(cl.[label_name]) = 'bottom funnel' THEN 2
                        ELSE 3
                    END,
                    cl.[label_name] ASC
            ) AS rn
        FROM [stg].[google_ads_campaign_label] AS cl
        WHERE LOWER(cl.[label_name]) IN ('bottom funnel', 'medium funnel')
    )

    SELECT
        ci.[campaign_id],
        cn.[campaign_name],
        fl.[label_name] AS [funnel_type]
    FROM campaign_ids AS ci
        LEFT JOIN campaign_names AS cn
            ON ci.[campaign_id] = cn.[campaign_id]
            AND cn.[rn] = 1
        LEFT JOIN funnel_labels AS fl
            ON ci.[campaign_id] = fl.[campaign_id]
            AND fl.[rn] = 1
GO
