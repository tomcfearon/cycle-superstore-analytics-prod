CREATE
-- OR ALTER
VIEW [marts].[vw_fct_google_daily_product_performance]
AS
    SELECT
        performance_date,
        product_id,
        destination,
        product_key,
        total_impressions,
        total_clicks
    FROM [int].[vw_int_google_daily_product_performance]
    WHERE product_key IS NOT NULL
