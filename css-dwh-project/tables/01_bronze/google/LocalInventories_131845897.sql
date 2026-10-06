CREATE TABLE [raw_google].[LocalInventories_131845897] (
    [_DATA_DATE]                      DATETIME2 (7)      NULL,
    [product_id]                      NVARCHAR (MAX)     NULL,
    [merchant_id]                     BIGINT             NULL,
    [aggregator_id]                   BIGINT             NULL,
    [store_code]                      NVARCHAR (MAX)     NULL,
    [price]                           NVARCHAR (MAX)     NULL,
    [sale_price]                      NVARCHAR (MAX)     NULL,
    [sale_price_effective_start_date] DATETIMEOFFSET (7) NULL,
    [sale_price_effective_end_date]   DATETIMEOFFSET (7) NULL,
    [availability]                    NVARCHAR (MAX)     NULL,
    [quantity]                        BIGINT             NULL,
    [pickup_method]                   NVARCHAR (MAX)     NULL,
    [pickup_sla]                      NVARCHAR (MAX)     NULL,
    [instore_product_location]        NVARCHAR (MAX)     NULL
);
GO

