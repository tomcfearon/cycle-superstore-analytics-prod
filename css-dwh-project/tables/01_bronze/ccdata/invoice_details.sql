CREATE TABLE [raw_ccdata].[InvoiceDetails] (
    [TransType]             TINYINT         NULL,
    [InvoiceNo]             VARCHAR (12)    NULL,
    [StockCode]             VARCHAR (50)    NULL,
    [Price]                 DECIMAL (19, 2) NULL,
    [Qty]                   INT             NULL,
    [VATValue]              DECIMAL (19, 2) NULL,
    [ReturnToStock]         VARCHAR (15)    NULL,
    [Cost]                  DECIMAL (19, 2) NULL,
    [Description]           VARCHAR (255)   NULL,
    [Reason]                VARCHAR (255)   NULL,
    [GroupSeqNo]            INT             NULL,
    [QtyTaken]              INT             NULL,
    [AnalysisDept]          VARCHAR (15)    NULL,
    [OrigPrice]             DECIMAL (19, 2) NULL,
    [OrigVATValue]          DECIMAL (19, 2) NULL,
    [Credited]              BIT             NULL,
    [CreditNo]              VARCHAR (12)    NULL,
    [TaxCode]               TINYINT         NULL,
    [StockPrice]            DECIMAL (19, 2) NULL,
    [SiteNo]                TINYINT         NULL,
    [StockLocation]         VARCHAR (50)    NULL,
    [DiscountApprovedBy]    INT             NULL,
    [MultiBuyDiscount]      BIT             NULL,
    [BrakeSetup]            INT             NULL,
    [row_modified_datetime] DATETIME        NULL -- ERP trigger-stamped; used for incremental ADF watermark loading
) ON [PRIMARY];


GO
-- Supports the header/detail join and the product-key mapping lookup on StockCode
CREATE NONCLUSTERED INDEX [ix_invoice_details_transtype_invoiceno]
    ON [raw_ccdata].[InvoiceDetails]([TransType], [InvoiceNo])
    INCLUDE([StockCode], [Price], [Qty], [VATValue], [Cost], [Description], [GroupSeqNo], [Credited], [CreditNo]);