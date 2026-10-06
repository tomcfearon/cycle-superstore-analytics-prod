CREATE TABLE [raw_ccdata].[QuotationDetails] (
    [QuoteNo]            VARCHAR (12)    NULL,
    [ModelNo]            VARCHAR (50)    NULL,
    [Make]               VARCHAR (50)    NULL,
    [Price]              DECIMAL (19, 2) NULL,
    [Qty]                INT             NULL,
    [ItemType]           TINYINT         NULL,
    [ItemPrice]          DECIMAL (19, 2) NULL,
    [GroupSeqNo]         INT             NULL,
    [Description]        VARCHAR (255)   NULL,
    [AnalysisDept]       VARCHAR (15)    NULL,
    [TaxCode]            TINYINT         NULL,
    [StockPrice]         DECIMAL (19, 2) NULL,
    [SiteNo]             TINYINT         NULL,
    [Reason]             VARCHAR (255)   NULL,
    [DiscountApprovedBy] INT             NULL,
    [MultiBuyDiscount]   BIT             NULL
) ON [PRIMARY];


GO
-- Header/detail join key
CREATE NONCLUSTERED INDEX [ix_quotation_details_quoteno]
    ON [raw_ccdata].[QuotationDetails]([QuoteNo])
    INCLUDE([ModelNo], [Qty]);