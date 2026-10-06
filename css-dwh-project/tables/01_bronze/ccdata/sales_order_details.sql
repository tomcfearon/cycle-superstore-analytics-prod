CREATE TABLE [raw_ccdata].[SaleOrderDetails] (
    [TransType]          TINYINT         NULL,
    [InvoiceNo]          VARCHAR (12)    NULL,
    [StockCode]          VARCHAR (50)    NULL,
    [Price]              DECIMAL (19, 2) NULL,
    [Qty]                INT             NULL,
    [VATValue]           DECIMAL (19, 2) NULL,
    [Cost]               DECIMAL (19, 2) NULL,
    [Description]        VARCHAR (255)   NULL,
    [Reason]             VARCHAR (255)   NULL,
    [GroupSeqNo]         INT             NULL,
    [QtyTaken]           INT             NULL,
    [AnalysisDept]       VARCHAR (15)    NULL,
    [OrigPrice]          DECIMAL (19, 2) NULL,
    [OrigVATValue]       DECIMAL (19, 2) NULL,
    [TaxCode]            TINYINT         NULL,
    [ModelNo]            VARCHAR (50)    NULL,
    [StatusItemType]     TINYINT         NULL,
    [StockPrice]         DECIMAL (19, 2) NULL,
    [SiteNo]             TINYINT         NULL,
    [StockLocation]      VARCHAR (50)    NULL,
    [RequestID]          INT             NULL,
    [BikePulled]         TINYINT         NULL,
    [DiscountApprovedBy] INT             NULL,
    [MultiBuyDiscount]   BIT             NULL,
    [BrakeSetup]         INT             NULL
) ON [PRIMARY];


GO
-- Header/detail join, same pattern as InvoiceDetails
CREATE NONCLUSTERED INDEX [ix_sales_order_details_transtype_invoiceno]
    ON [raw_ccdata].[SaleOrderDetails]([TransType], [InvoiceNo])
    INCLUDE([StockCode], [Qty], [Price]);