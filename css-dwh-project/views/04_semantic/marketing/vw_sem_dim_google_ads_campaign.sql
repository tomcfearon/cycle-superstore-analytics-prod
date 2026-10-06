-- Purpose: Expose the Google Ads campaign dimension to reporting with friendly names.
CREATE
-- OR ALTER
VIEW [dbo].[51 - Google Ads Campaign] AS
SELECT
    [campaign_id]   AS [Campaign ID],
    [campaign_name] AS [Campaign Name],
    [funnel_type]   AS [Funnel Type]
FROM [marts].[vw_dim_google_ads_campaign]
GO
