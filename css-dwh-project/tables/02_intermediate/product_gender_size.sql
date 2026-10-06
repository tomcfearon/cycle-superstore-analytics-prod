CREATE TABLE [int].[dim_product_size_gender] (
    [product_key] [nvarchar](50) NOT NULL,
    [size] [nvarchar](50) NULL,
    [gender] [nvarchar](20) NULL
    ) ON [PRIMARY]
GO

ALTER TABLE [int].[dim_product_size_gender] ADD CONSTRAINT [PK_dim_product_size_gender] PRIMARY KEY CLUSTERED ([product_key] ASC)
    WITH (
            STATISTICS_NORECOMPUTE = OFF,
            IGNORE_DUP_KEY = OFF,
            ONLINE = OFF,
            OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
            ) ON [PRIMARY]
GO
