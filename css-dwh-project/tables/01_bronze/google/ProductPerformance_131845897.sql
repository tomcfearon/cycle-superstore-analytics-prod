CREATE TABLE [raw_google].[vw_daily_product_performance]
(

    [partition_date]    DATE           NOT NULL,
    [offer_id]          NVARCHAR (255) NOT NULL,
    [destination]       NVARCHAR (20)  NULL,
    [total_impressions] BIGINT         NULL,
    [total_clicks]      BIGINT         NULL
);
GO
