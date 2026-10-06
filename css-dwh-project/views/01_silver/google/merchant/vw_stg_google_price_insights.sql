-- Source: BigQuery Data Transfer Service - Google Merchant Center (Price Insights report).
-- Purpose: Product-level suggested pricing and predicted performance deltas (impressions/clicks/conversions) for pricing optimization.
-- Reference: https://docs.cloud.google.com/bigquery/docs/merchant-center-price-insights-schema
CREATE
-- OR ALTER
VIEW [stg].[google_price_insights] AS
SELECT
        t.[partition_date],
        t.[aggregator_id],
        t.[merchant_id],
        t.[id],
        t.[title],
        t.[brand],
        -- price fields: BigQuery view pre-converts from micro-units — values are already in EUR
        t.[price_value]           AS [price],
        t.[suggested_price_value] AS [suggested_price],
        t.[predicted_impressions_change_fraction],
        t.[predicted_clicks_change_fraction],
        t.[predicted_conversions_change_fraction],
        t.[offer_id] as product_key,
        t.[product_type_l1],
        t.[product_type_l2],
        t.[product_type_l3],
        t.[product_type_l4],
        t.[product_type_l5],
        t.[category_l1],
        t.[category_l2],
        t.[category_l3],
        t.[category_l4],
        t.[category_l5]
    FROM
        [raw_google].[vw_PriceInsights] AS t  -- ADF pipeline writes to this table (vw_ prefix = BigQuery view name)
