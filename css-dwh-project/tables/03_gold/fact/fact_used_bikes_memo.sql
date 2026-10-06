
GO

GO
CREATE TABLE [marts].[fct_used_bikes_memo](
	[used_bike_id] [int] NULL,
	[service_order_number] [varchar](12) NULL,
	[web_bike_id] [int] NULL,
	[memo_date] [date] NULL,
	[sold_date] [date] NULL,
	[customer_code] [varchar](12) NULL,
	[sold_customer_code] [varchar](12) NULL,
	[salesperson1_key] [int] NULL,
	[salesperson2_key] [int] NULL,
	[sold_salesperson_key] [int] NULL,
	[description] [varchar](255) NULL,
	[brand] [varchar](50) NULL,
	[product_key] [varchar](52) NULL,
	[retail_price] [decimal](18, 2) NULL,
	[cost_price] [decimal](18, 2) NULL,
	[sale_price] [decimal](18, 2) NULL,
	[sold_price] [decimal](18, 2) NULL,
	[sold_payment_amount] [decimal](18, 2) NULL,
	[service_cost_price] [decimal](18, 2) NULL,
	[used_bike_status] [varchar](16) NULL,
	[used_bike_category] [varchar](50) NULL,
	[web_status] [char](30) NULL,
    [order_channel] [varchar](50) NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED COLUMNSTORE INDEX [marts_fct_used_bikes_memo__dbt_tmp_cci] ON [marts].[fct_used_bikes_memo] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
