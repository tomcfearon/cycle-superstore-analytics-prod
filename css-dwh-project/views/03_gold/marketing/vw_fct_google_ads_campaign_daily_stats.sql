-- Purpose: Thin mart projection over additive Google Ads campaign-day stats.
CREATE
-- OR ALTER
VIEW [marts].[vw_fct_google_ads_campaign_daily_stats] AS
    SELECT
        -- campaign_name, no need
        campaign_id,
        stats_date,
        total_clicks,
        total_impressions,
        total_cost,
        total_interactions
        -- funnel_type
    FROM [int].[vw_int_google_ads_campaign_daily_stats]
GO
