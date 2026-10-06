
GO

GO
CREATE TABLE [marts].[fct_purchase_orders](
	[product_key] [varchar](52) NOT NULL,
	[order_number] [varchar](12) NULL,
	[order_date] [date] NULL,
	[due_in_date] [date] NULL,
	[goods_in_datetime] [datetime] NULL,
	[supplier_code] [varchar](50) NULL,
	[purchase_order_employee_key] [int] NOT NULL,
	[goods_in_employee_key] [int] NOT NULL,
	[line_number] [int] NULL,
	[item_type] [int] NULL,
	[stock_location] [varchar](50) NULL,
	[quantity] [int] NULL,
	[quantity_received] [int] NULL,
	[cost] [decimal](19, 2) NULL,
	[retail_price] [decimal](19, 2) NULL,
	[trade_price] [decimal](19, 2) NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED COLUMNSTORE INDEX [marts_fct_purchase_orders__dbt_tmp_cci] ON [marts].[fct_purchase_orders] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
