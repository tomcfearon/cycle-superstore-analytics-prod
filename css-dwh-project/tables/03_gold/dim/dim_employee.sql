
GO

GO
CREATE TABLE [marts].[dim_employee](
	[employee_key] [int] NULL,
	[customer_code] [varchar](255) NULL,
	[employee_name] [nvarchar](50) NULL,
	[is_active] [bit] NULL,
	[is_engineer] [bit] NULL,
	[start_date] [date] NULL,
	[bonus] [float] NULL,
	[bonus_from_collections] [float] NULL,
	[employee_reference_number] [varchar](50) NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED COLUMNSTORE INDEX [marts_dim_employee__dbt_tmp_cci] ON [marts].[dim_employee] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_dim_employee_employee_key]
ON [marts].[dim_employee] ([employee_key])
INCLUDE ([customer_code], [employee_name], [is_active], [is_engineer], [start_date])
WHERE [employee_key] IS NOT NULL
GO

CREATE NONCLUSTERED INDEX [IX_dim_employee_customer_code]
ON [marts].[dim_employee] ([customer_code])
INCLUDE ([employee_key], [employee_name], [is_active], [is_engineer], [start_date])
WHERE [customer_code] IS NOT NULL
GO
