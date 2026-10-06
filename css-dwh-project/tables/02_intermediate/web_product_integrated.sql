CREATE TABLE [int].[web_product_integrated](
	[is_bike_product] [bit] NOT NULL,
	[stock_code] [varchar](100) NOT NULL,
	[web_product_id] [varchar](52) NULL,
	[web_parent_product_id] [varchar](20) NULL,
	[web_title] [varchar](500) NULL,
	[web_price] [varchar](30) NULL,
	[web_list_price] [varchar](30) NULL,
	[extended_warehouse_quantity] [varchar](20) NULL,
	[web_is_active] [bit] NULL,
	[web_is_list_hidden] [bit] NULL,
	[color] [varchar](100) NULL,
	[size] [varchar](100) NULL,
	[product_options_last_refreshed] [datetime2](0) NULL,
	[brand_name] [varchar](255) NULL,
	[web_link] [varchar](2048) NULL,
	[main_image_link] [varchar](2048) NULL,
	[additional_image_links] [nvarchar](max) NULL,
	[web_category_id] [int] NULL,
	[product_type] [varchar](255) NULL,
	[gpc_path] [varchar](1024) NULL,
	[web_html_details] [nvarchar](max) NULL,
	[web_gender] [varchar](50) NULL,
	[web_item_material] [varchar](255) NULL,
	[item_groupings_last_refreshed] [datetime2](0) NULL,
	[web_item_group_title] [varchar](500) NULL,
	[variant_descriptor] [varchar](255) NULL  -- colour/size suffix parsed from web_title parens by vw_web_product_integrated
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [int].[web_product_integrated] ADD  CONSTRAINT [PK_int_web_product_integrated] PRIMARY KEY CLUSTERED
(
	[is_bike_product] ASC,
	[stock_code] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
