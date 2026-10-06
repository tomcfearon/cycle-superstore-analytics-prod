CREATE
-- OR ALTER
VIEW [marts].[vw_fct_google_ads_campaign_conversions] AS
SELECT
    -- campaign_name, no need
    campaign_id,
    conversion_action_category,
    conversion_date,
    total_conversions,
    total_conversions_value
    -- funnel_type
FROM
    [int].[google_ads_campaign_conversions]
-- ORDER BY conversion_date DESC;
