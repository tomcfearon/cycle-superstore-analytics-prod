-- Source: BigQuery Data Transfer Service - Google Ads (CampaignLabel).
-- Purpose: Campaign-to-label mapping snapshot used for campaign classification and grouping.
-- Reference: https://docs.cloud.google.com/bigquery/docs/google-ads-transformation
CREATE
-- OR ALTER
VIEW [stg].[google_ads_campaign_label] AS
SELECT
        t.[campaign_id],
        t.[label_id],
        t.[campaign_label_campaign],
        t.[campaign_label_label],
        t.[campaign_label_resource_name],
        t.[campaign_name],
        t.[label_name],
        t.[label_resource_name],
        t.[_LATEST_DATE],
        t.[_DATA_DATE]
    FROM
        [raw_google].[ads_CampaignLabel_5605924582] AS t



