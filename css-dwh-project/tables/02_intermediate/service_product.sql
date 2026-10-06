-- Physical materialisation of SER- coded service/repair stock classification.
--
-- PK  : product_id — one row per individual stock item (serial number) from stg.product.
--
-- Populated by: [int].[usp_load_service_product]
CREATE TABLE [int].[service_product] (
    [product_id]             VARCHAR (50)  NOT NULL,
    [title]                  VARCHAR (255) NULL,
    [row_modified_datetime]  DATETIME      NOT NULL,
    [model_year]             VARCHAR (10)  NULL,
    [brand]                  VARCHAR (50)  NULL,
    [is_company_stock]       BIT           NOT NULL,
    [is_wheel]               BIT           NOT NULL,
    [is_fork]                BIT           NOT NULL,
    [is_pedal]               BIT           NOT NULL,
    CONSTRAINT [PK_int_service_product] PRIMARY KEY CLUSTERED ([product_id] ASC)
);
