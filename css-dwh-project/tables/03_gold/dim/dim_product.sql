
GO

GO
CREATE TABLE [marts].[dim_product]
(
    [product_key] [varchar](52) NOT NULL,
    [stock_code] [varchar](50) NULL,
    [brand] [varchar](255) NULL,
    [erp_brand] [varchar](255) NULL,
    [title] [varchar](255) NULL,
    [product_group_title] [varchar](255) NULL,
    [category] [varchar](255) NULL,
    [subcategory] [varchar](255) NULL,
    [retail_price] [decimal](18, 2) NULL,
    [cost_price] [decimal](18, 2) NULL,
    [average_cost_price] [decimal](18, 2) NULL,
    [selling_price_1] [decimal](18, 2) NULL,
    [selling_price_2] [decimal](18, 2) NULL,
    [selling_price_3] [decimal](18, 2) NULL,
    [selling_price_4] [decimal](18, 2) NULL,
    [selling_price_5] [decimal](18, 2) NULL,
    [selling_price_6] [decimal](18, 2) NULL,
    [selling_price_7] [decimal](18, 2) NULL,
    [sale_price] [decimal](18, 2) NULL,
    [trade_sale_price] [decimal](18, 2) NULL,
    [is_active] [bit] NULL,
    [is_on_web] [bit] NULL,
    [is_discontinued] [bit] NULL,
    [web_is_active] [bit] NULL,
    [web_is_list_hidden] [bit] NULL,
    [color] [varchar](50) NULL,
    [size] [varchar](50) NULL,
    [product_options_last_refreshed] [datetime2](0) NULL,
    [item_groupings_last_refreshed] [datetime2](0) NULL,
    [store_db_title] [varchar](255) NULL,
    [web_link] [varchar](2048) NULL,
    [main_image_link] [varchar](2048) NULL,
    [additional_image_links] [nvarchar](max) NULL,
    [web_category_path] [varchar](1024) NULL,
    [google_category] [varchar](1024) NULL,
    [html_details] [nvarchar](max) NULL,
    [gender] [varchar](10) NULL,
    [item_material] [varchar](255) NULL,
    -- Keep product_id as text because web and stock identifiers are alphanumeric keys.
    [product_id] [varchar](52) NULL,
    [product_group_id] [int] NULL,
    [web_price] [decimal](18, 2) NULL,
    [web_list_price] [decimal](18, 2) NULL,
    [extended_warehouse_quantity] [int] NULL,
    [web_is_bike_product] [bit] NULL,
    [model_year] [varchar](50) NULL,
    [is_new] [bit] NULL,
    [stock_type] [varchar](20) NULL,
    [bike_sundry] [varchar](10) NULL,
    [bike_category] [varchar](30) NULL,
    [electric_manual_sundry] [varchar](10) NULL,
    [main_bike_type] [varchar](30) NULL,
    [category_type] [varchar](30) NULL,
    [subcategory_type] [varchar](255) NULL,
    [variant_descriptor] [varchar](255) NULL,  -- colour/size suffix stripped from ERP title vs. product group title
    [is_distribution] [bit] NULL,
    [main_sundry_repairs] [varchar](10) NULL,
    -- Google Merchant Center pricing signals (latest partition per product)
    [benchmark_price] [decimal](18, 2) NULL,   -- market benchmark price from Price Competitiveness report
    [suggested_price] [decimal](18, 2) NULL,   -- suggested price from Price Insights report
    -- Derived presentation column
    [clean_product_name] [varchar](500) NULL,  -- product_group_title with brand, category/subcategory type, and common bike-type phrases removed
    [row_modified_datetime] [datetime2](0) NULL -- ERP-stamped datetime; used as watermark for incremental loading
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [marts].[dim_product] ADD  CONSTRAINT [PK_dim_product] PRIMARY KEY CLUSTERED
(
	[product_key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_dim_product_stock_code]
ON [marts].[dim_product] ([stock_code])
INCLUDE ([product_key])
WHERE [stock_code] IS NOT NULL
GO

CREATE NONCLUSTERED INDEX [IX_dim_stock_category_subcategory]
ON [marts].[dim_product] ([category], [subcategory])
INCLUDE ([product_key])
WHERE [category] IS NOT NULL
GO

CREATE NONCLUSTERED INDEX [IX_dim_stock_product_id]
ON [marts].[dim_product] ([product_id])
INCLUDE ([product_key])
WHERE [product_id] IS NOT NULL
GO

CREATE NONCLUSTERED INDEX [IX_dim_stock_product_group_id]
ON [marts].[dim_product] ([product_group_id])
INCLUDE ([product_key])
WHERE [product_group_id] IS NOT NULL
GO
