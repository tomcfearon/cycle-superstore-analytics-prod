CREATE
-- OR ALTER
VIEW [dbo].[13 - Google Ads Campaign Conversions] AS
SELECT
    [campaign_id]              AS [Campaign ID],
    [conversion_action_category] AS [Conversion Action Category],
    [conversion_date]            AS [Conversion Date],
    [total_conversions]          AS [Total Conversions],
    [total_conversions_value]    AS [Total Conversions Value]
FROM [marts].[fct_google_ads_campaign_conversions]
-- ORDER BY [Conversion Date] DESC;
