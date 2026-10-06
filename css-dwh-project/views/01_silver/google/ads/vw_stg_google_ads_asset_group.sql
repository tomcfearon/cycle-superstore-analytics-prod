-- Source: BigQuery Data Transfer Service - Google Ads (AssetGroup, PMax).
-- Purpose: Performance Max asset-group metadata including campaign linkage, URLs, name, and status.
-- Reference: https://docs.cloud.google.com/bigquery/docs/google-ads-transformation
CREATE
-- OR ALTER
VIEW [stg].[google_ads_asset_group] AS
SELECT
        t.[asset_group_id],
        t.[asset_group_campaign],
        t.[asset_group_final_mobile_urls],
        t.[asset_group_final_urls],
        t.[asset_group_name],
        t.[asset_group_status],
        t.[_LATEST_DATE],
        t.[_DATA_DATE]
    FROM
        [raw_google].[ads_AssetGroup_5605924582] AS t
