CREATE TABLE [marts].[fct_google_ads_campaign_conversions] (
    [campaign_name]              NVARCHAR (MAX) NULL,
    [campaign_id]                BIGINT         NULL,
    [conversion_action_category] NVARCHAR (MAX) NULL,
    [conversion_date]            DATE           NULL,
    [total_conversions]          FLOAT (53)     NULL,
    [total_conversions_value]    FLOAT (53)     NULL,
    [funnel_type]                NVARCHAR (MAX) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [marts_fct_google_ads_campaign_conversions_ci]
ON [marts].[fct_google_ads_campaign_conversions] ([campaign_id], [conversion_date])
GO

-- SELECT TOP (1000)
--     campaign_name,
--     campaign_id,
--     conversion_action_category,
--     conversion_date,
--     total_conversions,
--     total_conversions_value,
--     funnel_type
-- FROM
--     [marts].[fct_google_ads_campaign_conversions]
-- ORDER BY conversion_date DESC;
-- GO
