CREATE TABLE [raw_ccdata].[PurchaseOrderDetails] (
    [OrderNo]       VARCHAR (12)    NULL,
    [Qty]           INT             NULL,
    [Cost]          DECIMAL (19, 3) NULL,
    [QtyReceived]   INT             NULL,
    [SeqNo]         INT             NULL,
    [ItemType]      TINYINT         NULL,
    [ModelNo]       VARCHAR (50)    NULL,
    [StockLocation] VARCHAR (50)    NULL,
    [Make]          VARCHAR (50)    NULL,
    [Description]   VARCHAR (255)   NULL,
    [Colour]        VARCHAR (50)    NULL,
    [PartNo]        VARCHAR (50)    NULL,
    [SiteNo]        TINYINT         NULL,
    [BookedDate]    DATETIME        NULL,
    [RetailPrice]   DECIMAL (19, 3) NULL,
    [TradePrice]    DECIMAL (19, 3) NULL,
    [SpecialPrice]  BIT             NULL
) ON [PRIMARY];


GO
-- Header/detail join key
CREATE NONCLUSTERED INDEX [ix_purchase_order_details_orderno]
    ON [raw_ccdata].[PurchaseOrderDetails]([OrderNo])
    INCLUDE([ModelNo], [Qty], [Cost]);