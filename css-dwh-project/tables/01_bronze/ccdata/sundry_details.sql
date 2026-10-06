CREATE TABLE [raw_ccdata].[SundryDetails] (
    [TransType]             TINYINT         NULL,
    [InvoiceNo]             VARCHAR (12)    NULL,
    [StockCode]             VARCHAR (50)    NULL,
    [Price]                 DECIMAL (19, 2) NULL,
    [Qty]                   INT             NULL,
    [VATValue]              DECIMAL (19, 2) NULL,
    [Cost]                  DECIMAL (19, 2) NULL,
    [Description]           VARCHAR (255)   NULL,
    [GroupSeqNo]            INT             NULL,
    [AnalysisDept]          VARCHAR (15)    NULL,
    [TaxCode]               TINYINT         NULL,
    [StockPrice]            DECIMAL (19, 2) NULL,
    [SiteNo]                TINYINT         NULL,
    [StockLocation]         VARCHAR (50)    NULL,
    [RefundItem]            BIT             NULL,
    [MultiBuyDiscount]      BIT             NULL,
    [Reason]                VARCHAR (255)   NULL,
    [row_modified_datetime] DATETIME        NULL -- ERP trigger-stamped; used for incremental ADF watermark loading
) ON [PRIMARY];


GO
-- Confirmed by sys.dm_db_missing_index_details on css-dwh-dev
CREATE NONCLUSTERED INDEX [ix_sundry_details_transtype_invoiceno]
    ON [raw_ccdata].[SundryDetails]([TransType], [InvoiceNo])
    INCLUDE([StockCode], [Price], [Qty], [VATValue], [Cost], [Description], [GroupSeqNo], [StockPrice], [RefundItem]);