-- Source: BigQuery Data Transfer Service - Google Ads (AccountConversionStats).
-- Purpose: Account-level conversion metrics with conversion-action, time, and device segmentation.
-- Reference: https://docs.cloud.google.com/bigquery/docs/google-ads-transformation
CREATE
-- OR ALTER
VIEW [stg].[google_ads_account_conversion_stats] AS
SELECT
        t.[customer_id],
        t.[metrics_conversions],
        t.[metrics_conversions_value],
        t.[metrics_value_per_conversion],
        t.[segments_ad_network_type],
        t.[segments_click_type],
        t.[segments_conversion_action],
        t.[segments_conversion_action_category],
        t.[segments_conversion_action_name],
        t.[segments_date],
        t.[segments_day_of_week],
        t.[segments_device],
        t.[segments_month],
        t.[segments_quarter],
        t.[segments_slot],
        t.[segments_week],
        t.[segments_year],
        t.[_LATEST_DATE],
        t.[_DATA_DATE]
    FROM
        [raw_google].[ads_AccountConversionStats_5605924582] AS t
