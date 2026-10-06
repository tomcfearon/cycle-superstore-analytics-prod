CREATE TABLE [raw_ccdata].[PurchaseOrderHeader] (
    [OrderNo]             VARCHAR (12)    NULL,
    [Salesperson]         VARCHAR (50)    NULL,
    [SupplierCode]        VARCHAR (50)    NULL,
    [OrderDate]           DATETIME        NULL,
    [DueIn]               DATETIME        NULL,
    [OrderRef]            VARCHAR (255)   NULL,
    [Notes]               VARCHAR (4000)  NULL,
    [SiteNo]              TINYINT         NULL,
    [AdditionalCost]      DECIMAL (19, 2) NULL,
    [OrderRefTotal]       DECIMAL (19, 2) NULL,
    [ConversionRateGBP]   DECIMAL (4, 2)  NULL,
    [DeliveryNoteNo]      VARCHAR (50)    NULL,
    [TransType]           TINYINT         NULL,
    [GoodsInDate]         DATETIME        NULL,
    [GoodsInSalesPerson]  VARCHAR (50)    NULL,
    [SettlementDiscount]  DECIMAL (19, 2) NULL,
    -- Preserve live raw landing fields surfaced by the source purchase-order feed.
    [BulkOrder]           INT             NULL,
    [DiscountReceived]    DECIMAL (19, 2) NULL,
    [ShippingCostPerBike] DECIMAL (19, 2) NULL
) ON [PRIMARY];


GO
-- Header/detail join key
CREATE NONCLUSTERED INDEX [ix_purchase_order_header_orderno]
    ON [raw_ccdata].[PurchaseOrderHeader]([OrderNo])
    INCLUDE([Salesperson], [SupplierCode]);