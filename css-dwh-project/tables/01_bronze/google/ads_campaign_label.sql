CREATE TABLE [raw_google].[ads_CampaignLabel_5605924582] (
    [campaign_id]                  BIGINT         NULL,
    [label_id]                     BIGINT         NULL,
    [campaign_label_campaign]      NVARCHAR (MAX) NULL,
    [campaign_label_label]         NVARCHAR (MAX) NULL,
    [campaign_label_resource_name] NVARCHAR (MAX) NULL,
    [campaign_name]                NVARCHAR (MAX) NULL,
    [label_name]                   NVARCHAR (MAX) NULL,
    [label_resource_name]          NVARCHAR (MAX) NULL,
    [_LATEST_DATE]                 DATETIME2 (7)  NULL,
    [_DATA_DATE]                   DATETIME2 (7)  NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];