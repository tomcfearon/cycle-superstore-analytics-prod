-- Source: BigQuery Data Transfer Service - Google Ads (BudgetStats).
-- Purpose: Campaign-budget performance and recommendation deltas (clicks/cost/interactions/views) by date.
-- Reference: https://docs.cloud.google.com/bigquery/docs/google-ads-transformation
CREATE
-- OR ALTER
VIEW [stg].[google_ads_budget_stats] AS
SELECT
        t.[campaign_budget_id],
        t.[campaign_id],
        t.[customer_id],
        t.[campaign_budget_recommended_budget_estimated_change_weekly_clicks],
        t.[campaign_budget_recommended_budget_estimated_change_weekly_cost_micros],
        t.[campaign_budget_recommended_budget_estimated_change_weekly_interactions],
        t.[campaign_budget_recommended_budget_estimated_change_weekly_views],
        t.[campaign_name],
        t.[campaign_status],
        t.[metrics_all_conversions],
        t.[metrics_all_conversions_from_interactions_rate],
        t.[metrics_all_conversions_value],
        t.[metrics_average_cost],
        t.[metrics_average_cpc],
        t.[metrics_average_cpe],
        t.[metrics_average_cpm],
        t.[metrics_average_cpv],
        t.[metrics_trueview_average_cpv],
        t.[metrics_clicks],
        t.[metrics_conversions],
        t.[metrics_conversions_from_interactions_rate],
        t.[metrics_conversions_value],
        t.[metrics_cost_micros],
        t.[metrics_cost_per_all_conversions],
        t.[metrics_cost_per_conversion],
        t.[metrics_cross_device_conversions],
        t.[metrics_ctr],
        t.[metrics_engagement_rate],
        t.[metrics_engagements],
        t.[metrics_impressions],
        t.[metrics_interaction_event_types],
        t.[metrics_interaction_rate],
        t.[metrics_interactions],
        t.[metrics_value_per_all_conversions],
        t.[metrics_value_per_conversion],
        t.[metrics_video_trueview_view_rate],
        t.[metrics_video_trueview_views],
        t.[metrics_video_view_rate],
        t.[metrics_video_views],
        t.[metrics_view_through_conversions],
        t.[segments_date],
        t.[_LATEST_DATE],
        t.[_DATA_DATE]
    FROM
        [raw_google].[ads_BudgetStats_5605924582] AS t
