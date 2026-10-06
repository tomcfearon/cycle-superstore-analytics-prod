-- Source: BigQuery Data Transfer Service - Google Ads (AccountBasicStats).
-- Purpose: Account-level daily basic performance metrics (clicks, conversions, cost, impressions, interactions) segmented by date/network/device/slot.
-- Reference: https://docs.cloud.google.com/bigquery/docs/google-ads-transformation
CREATE
-- OR ALTER
VIEW [stg].[google_ads_account_basic] AS
SELECT
        t.[customer_id],
        t.[metrics_clicks],
        t.[metrics_conversions],
        t.[metrics_conversions_value],
        t.[metrics_cost_micros],
        t.[metrics_impressions],
        t.[metrics_interaction_event_types],
        t.[metrics_interactions],
        t.[metrics_view_through_conversions],
        t.[segments_ad_network_type],
        t.[segments_date],
        t.[segments_device],
        t.[segments_slot],
        t.[_LATEST_DATE],
        t.[_DATA_DATE]
    FROM
        [raw_google].[ads_AccountBasicStats_5605924582] AS t
