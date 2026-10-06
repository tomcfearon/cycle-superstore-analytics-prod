CREATE TABLE [marts].[fct_google_daily_product_performance] (
    [performance_date]  DATE           NOT NULL,
    [product_id]        NVARCHAR (255) NOT NULL,
    [destination]       NVARCHAR (20)  NULL,
    [product_key]         VARCHAR (52)   NULL,
    [total_impressions] BIGINT         NULL,
    [total_clicks]      BIGINT         NULL
) ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [marts_fct_google_daily_product_performance_ci]
ON [marts].[fct_google_daily_product_performance] ([product_id], [performance_date])
GO
