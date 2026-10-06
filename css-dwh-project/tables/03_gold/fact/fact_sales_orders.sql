
GO

GO
CREATE TABLE [marts].[fct_sales_orders]
(
	[transaction_key] [varchar](20) NULL,
	[order_time] [time](0) NULL,
	[order_date] [date] NULL,
	[employee_key] [int] NOT NULL,
	[customer_code] [varchar](12) NULL,
	[deposit_value] [decimal](19, 2) NULL,
	[payment_to_date] [decimal](19, 2) NULL,
	[collection_date] [date] NULL,
	[box_number] [int] NULL,
	[order_status] [varchar](50) NULL,
	[web_order_id] [int] NULL,
	[is_confirmed] [bit] NULL,
	[bike_location] [varchar](255) NULL,
	[product_key] [varchar](52) NOT NULL,
	[price] [decimal](19, 2) NULL,
	[quantity] [int] NULL,
	[vat_amount] [decimal](19, 2) NULL,
	[cost] [numeric](34, 6) NULL,
	[description] [varchar](255) NULL,
	[line_sequence_number] [int] NULL,
	[quantity_taken] [int] NULL,
	[price_before_discount] [decimal](30, 2) NULL,
	[request_id] [int] NULL,
	[is_pulled] [int] NULL,
	[approver_key] [int] NULL,
	[collection_employee_key] [int] NULL,
	[order_channel] [varchar](50) NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED COLUMNSTORE INDEX [marts_fct_sales_orders__dbt_tmp_cci] ON [marts].[fct_sales_orders] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
