CREATE
-- OR ALTER
VIEW [dbo].[14 - Google Product Performance]
AS
    SELECT
        [performance_date]  AS [Performance Date],
        [destination]       AS [Destination],
        [product_key]         AS [Product Key],
        [total_impressions] AS [Total Impressions],
        [total_clicks]      AS [Total Clicks]
    FROM
        [marts].[fct_google_daily_product_performance]
GO



