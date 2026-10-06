SET NOCOUNT ON;

DECLARE @t0 datetime2(3) = SYSDATETIME();

-- Manual runner for the additive campaign-day Google Ads fact.
EXEC [marts].[usp_load_fct_google_ads_campaign_daily_stats];

SELECT DATEDIFF(ms, @t0, SYSDATETIME()) AS duration_ms;
