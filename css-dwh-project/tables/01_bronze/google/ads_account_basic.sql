CREATE TABLE [raw_google].[ads_AccountBasicStats_5605924582] (
    [customer_id]                      BIGINT         NULL,
    [metrics_clicks]                   BIGINT         NULL,
    [metrics_conversions]              FLOAT          NULL,
    [metrics_conversions_value]        FLOAT          NULL,
    [metrics_cost_micros]              BIGINT         NULL,
    [metrics_impressions]              BIGINT         NULL,
    [metrics_interaction_event_types]  NVARCHAR (MAX) NULL,
    [metrics_interactions]             BIGINT         NULL,
    [metrics_view_through_conversions] BIGINT         NULL,
    [segments_ad_network_type]         NVARCHAR (MAX) NULL,
    [segments_date]                    DATETIME2 (7)  NULL,
    [segments_device]                  NVARCHAR (MAX) NULL,
    [segments_slot]                    NVARCHAR (MAX) NULL,
    [_LATEST_DATE]                     DATETIME2 (7)  NULL,
    [_DATA_DATE]                       DATETIME2 (7)  NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];