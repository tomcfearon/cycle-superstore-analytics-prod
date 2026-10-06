-- Purpose: Expose additive Google Ads campaign-day performance to the semantic layer.
CREATE
-- OR ALTER
VIEW [dbo].[15 - Google Ads Campaign Stats] AS
    SELECT
        [campaign_id]        AS [Campaign ID],
        [stats_date]         AS [Stats Date],
        [total_clicks]       AS [Total Clicks],
        [total_impressions]  AS [Total Impressions],
        [total_cost]         AS [Total Cost],
        [total_interactions] AS [Total Interactions]
    FROM [marts].[fct_google_ads_campaign_daily_stats]
GO
