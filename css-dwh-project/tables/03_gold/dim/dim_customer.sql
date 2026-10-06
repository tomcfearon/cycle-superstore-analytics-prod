CREATE TABLE [marts].[dim_customer](
	[customer_code] [varchar](50) NOT NULL,
	[customer_name] [varchar](255) NULL,
	[customer_type] [varchar](50) NULL,
	[price_band] [int] NULL,
	[company] [varchar](255) NULL,
	[is_on_stop] [bit] NULL,
	[is_archived] [bit] NULL,
	[is_confirmed_female] [bit] NULL,
	[credit_terms] [varchar](50) NULL,
	[credit_limit] [decimal](19, 4) NULL,
	[credit_balance] [decimal](19, 4) NULL,
	[account_opened_date] [datetime2](0) NULL,
	[last_modified_date] [datetime2](0) NULL,
	[row_modified_datetime] [datetime2](0) NULL,
	[last_in_store_date] [datetime2](0) NULL,
	[email] [varchar](320) NULL,
	[web_customer_id] [bigint] NULL,
	[web_cp_connection] [varchar](50) NULL,
	[web_first_name] [varchar](100) NULL,
	[web_last_name] [varchar](100) NULL,
	[web_company] [varchar](255) NULL,
	[web_phone] [varchar](50) NULL,
	[web_address_line_1] [varchar](255) NULL,
	[web_address_line_2] [varchar](255) NULL,
	[web_postal_code] [varchar](20) NULL,
	[web_state_code] [varchar](20) NULL,
	[web_state] [varchar](100) NULL,
	[web_city] [varchar](100) NULL,
	[web_country_code] [varchar](10) NULL,
	[web_customer_type] [varchar](50) NULL,
	[web_created_at] [datetime2](0) NULL,
	[retail_trade] [varchar](10) NULL
) ON [PRIMARY]
GO

ALTER TABLE [marts].[dim_customer] ADD CONSTRAINT [PK_dim_customer] PRIMARY KEY CLUSTERED
(
	[customer_code] ASC
)
GO

CREATE NONCLUSTERED INDEX [IX_dim_customer_web_customer_id]
ON [marts].[dim_customer] ([web_customer_id])
INCLUDE ([customer_code])
WHERE [web_customer_id] IS NOT NULL
GO

CREATE NONCLUSTERED INDEX [IX_dim_customer_email]
ON [marts].[dim_customer] ([email])
INCLUDE ([customer_code])
WHERE [email] IS NOT NULL
GO
