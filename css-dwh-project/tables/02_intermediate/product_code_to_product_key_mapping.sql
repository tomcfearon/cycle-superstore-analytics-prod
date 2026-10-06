-- Physical materialisation of the stock-code → stock-key mapping.
--
-- PK  : product_id  — every row represents one individual stock item (serial number).
--         Multiple serials of the same model share the same product_key, so
--         product_key is NOT unique at row level and cannot be the PK.
-- NCI : product_key   — supports mart / quantities views that join on product_key.
-- NCI : stock_code  — supports brand-prefix lookups.
--
-- Populated by: [int].[usp_load_stock_code_mapping]
-- See also    : sql/warehouse/procedures/load/int/usp_load_int_stock_code_mapping.sql
CREATE TABLE [int].[product_code_to_product_key_mapping] (
    [product_key]           VARCHAR (52) NOT NULL,
    [product_id]            VARCHAR (52) NOT NULL,
    [stock_code]            VARCHAR (52) NOT NULL,
    [row_modified_datetime] DATETIME     NOT NULL,
    CONSTRAINT [PK_int_product_code_to_product_key_mapping] PRIMARY KEY CLUSTERED ([product_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_int_sktm_product_key]
    ON [int].[product_code_to_product_key_mapping]([product_key])
    INCLUDE([product_id], [stock_code]);


GO
CREATE NONCLUSTERED INDEX [IX_int_sktm_stock_code]
    ON [int].[product_code_to_product_key_mapping]([stock_code])
    INCLUDE([product_id], [product_key]);