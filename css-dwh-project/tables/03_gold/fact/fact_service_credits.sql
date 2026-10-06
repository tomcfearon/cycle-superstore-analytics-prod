
CREATE TABLE [marts].[fct_service_credits]
(
	[transaction_key] [varchar](20) NULL,
	[credit_date] [date] NULL,
	[credit_time] [time](0) NULL,
	[order_date] [date] NULL,
	[customer_code] [varchar](12) NULL,
	[salesperson_employee_key] [int] NULL,
	[engineer_key] [int] NULL,
	[creditor_key] [int] NULL,
	[approver_key] [int] NULL,
	[invoice_connection_number] [varchar](12) NULL,
	[order_number] [varchar](12) NULL,
	[web_order_id] [int] NULL,
	[last_modified_datetime] [datetime] NULL,
	[row_modified_datetime] [datetime] NULL,
	[product_key] [varchar](52) NULL,
	[description] [varchar](255) NULL,
	[line_sequence_number] [int] NULL,
	[quantity] [int] NULL,
	[price_before_discount] [decimal](19, 2) NULL,
	[price] [decimal](19, 2) NULL,
	[vat_amount] [decimal](19, 2) NULL,
	[cost] [numeric](34, 6) NULL,
	[order_channel] [varchar](50) NULL,
	service_type_key INT NULL    -- FK to dim_service_type; inherited from parent service invoice
) ON [PRIMARY]
GO
CREATE CLUSTERED COLUMNSTORE INDEX [marts_fct_service_credits__dbt_tmp_cci] ON [marts].[fct_service_credits] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
