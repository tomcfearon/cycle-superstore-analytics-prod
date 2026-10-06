CREATE TABLE [raw_ccdata].[RepairsDetails] (
    [FaultNo]               VARCHAR (12)    NULL,
    [StockCode]             VARCHAR (50)    NULL,
    [Description]           VARCHAR (255)   NULL,
    [Qty]                   INT             NULL,
    [CostPrice]             DECIMAL (19, 2) NULL,
    [SellPrice]             DECIMAL (19, 4) NULL,
    [GroupSeqNo]            INT             NULL,
    [SiteNo]                TINYINT         NULL,
    [StockLocation]         VARCHAR (50)    NULL,
    [Credited]              BIT             NULL,
    [CreditNo]              VARCHAR (12)    NULL,
    [Broken]                BIT             NULL,
    [Reason]                VARCHAR (255)   NULL,
    [ItemType]              TINYINT         NULL,
    [RequestID]             INT             NULL,
    [DiscountApprovedBy]    INT             NULL,
    [MultiBuyDiscount]      BIT             NULL,
    [StockPrice]            DECIMAL (19, 2) NULL,
    [TaxCode]               TINYINT         NULL,
    [QtyTaken]              INT             NULL,
    [row_modified_datetime] DATETIME        NULL -- ERP trigger-stamped; used for incremental ADF watermark loading
) ON [PRIMARY];


GO
-- Header/detail join key back to Repairs
CREATE NONCLUSTERED INDEX [ix_repairs_details_faultno]
    ON [raw_ccdata].[RepairsDetails]([FaultNo])
    INCLUDE([StockCode], [Qty], [CostPrice], [SellPrice]);