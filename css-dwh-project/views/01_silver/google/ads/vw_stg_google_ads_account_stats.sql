-- Source: BigQuery Data Transfer Service - Google Ads (AccountStats).
-- Purpose: Account-level core performance and Active View metrics with time/network/device segmentation.
-- Reference: https://docs.cloud.google.com/bigquery/docs/google-ads-transformation
CREATE
-- OR ALTER
VIEW [stg].[google_ads_account_stats] AS
SELECT
        t.[customer_id],
        t.[metrics_active_view_cpm],
        t.[metrics_active_view_ctr],
        t.[metrics_active_view_impressions],
        t.[metrics_active_view_measurability],
        t.[metrics_active_view_measurable_cost_micros],
        t.[metrics_active_view_measurable_impressions],
        t.[metrics_active_view_viewability],
        t.[metrics_average_cost],
        t.[metrics_average_cpc],
        t.[metrics_average_cpm],
        t.[metrics_clicks],
        t.[metrics_conversions],
        t.[metrics_conversions_from_interactions_rate],
        t.[metrics_conversions_value],
        t.[metrics_cost_micros],
        t.[metrics_cost_per_conversion],
        t.[metrics_ctr],
        t.[metrics_impressions],
        t.[metrics_interaction_event_types],
        t.[metrics_interaction_rate],
        t.[metrics_interactions],
        t.[metrics_value_per_conversion],
        t.[segments_ad_network_type],
        t.[segments_click_type],
        t.[segments_date],
        t.[segments_day_of_week],
        t.[segments_device],
        t.[segments_month],
        t.[segments_quarter],
        t.[segments_week],
        t.[segments_year],
        t.[_LATEST_DATE],
        t.[_DATA_DATE]
    FROM
        [raw_google].[ads_AccountStats_5605924582] AS t
