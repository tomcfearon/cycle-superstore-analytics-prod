-- Purpose: Persist additive Google Ads campaign-day performance for semantic reporting.
CREATE TABLE [marts].[fct_google_ads_campaign_daily_stats] (
    [campaign_name]      NVARCHAR (MAX)  NULL,
    [campaign_id]        BIGINT          NULL,
    [stats_date]         DATE            NULL,
    [total_clicks]       BIGINT          NULL,
    [total_impressions]  BIGINT          NULL,
    [total_cost]         DECIMAL (19, 6) NULL,
    [total_interactions] BIGINT          NULL,
    [funnel_type]        NVARCHAR (MAX)  NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [marts_fct_google_ads_campaign_daily_stats_ci]
ON [marts].[fct_google_ads_campaign_daily_stats] ([campaign_id], [stats_date])
GO
