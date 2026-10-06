CREATE TABLE [raw_css2].[ItemGroupings_T] (
    [item_group_id] INT            NULL,
    [link]          NVARCHAR (200) NULL,
    [image_link]    NVARCHAR (400) NULL,
    [image_links]   NVARCHAR (MAX) NULL,
    [BrandName]     NVARCHAR (MAX) NULL,
    [idCategory]    INT            NULL,
    [product_type]  NVARCHAR (400) NULL,
    [gpc_path]      NVARCHAR (400) NULL,
    [details]       NVARCHAR (MAX) NULL,
    [gender_name]   NVARCHAR (100) NULL,
    [material_name] NVARCHAR (100) NULL,
    [LastRefreshed] DATETIME2 (0)  NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];