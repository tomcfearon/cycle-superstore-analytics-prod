-- Source: BigQuery Data Transfer Service - Google Ads (CampaignConversionStats).
-- Purpose: Campaign-level conversion metrics with conversion-action, time, and slot segmentation.
-- Reference: https://docs.cloud.google.com/bigquery/docs/google-ads-transformation
CREATE
-- OR ALTER
VIEW [stg].[google_ads_campaign_conversion_stats] AS
SELECT
        t.[campaign_id],
        t.[customer_id],
        t.[campaign_base_campaign],
        t.[metrics_conversions],
        t.[metrics_conversions_value],
        t.[metrics_value_per_conversion],
        t.[segments_ad_network_type],
        t.[segments_conversion_action],
        t.[segments_conversion_action_category],
        t.[segments_conversion_action_name],
        t.[segments_conversion_attribution_event_type],
        t.[segments_date],
        t.[segments_day_of_week],
        t.[segments_month],
        t.[segments_quarter],
        t.[segments_slot],
        t.[segments_week],
        t.[segments_year],
        t.[_LATEST_DATE],
        t.[_DATA_DATE]
    FROM
        [raw_google].[ads_CampaignConversionStats_5605924582] AS t
-- ORDER BY t.[_DATA_DATE] DESC;
