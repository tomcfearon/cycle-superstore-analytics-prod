-- Purpose: Thin mart projection over the latest Google Ads campaign dimension.
CREATE
-- OR ALTER
VIEW [marts].[vw_dim_google_ads_campaign] AS
SELECT
    [campaign_id],
    [campaign_name],
    [funnel_type]
FROM [int].[vw_int_dim_google_ads_campaign]
GO