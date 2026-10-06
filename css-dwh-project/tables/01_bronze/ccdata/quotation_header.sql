CREATE TABLE [raw_ccdata].[Quotations] (
    [QuoteNo]      VARCHAR (12)    NULL,
    [QuoteDate]    DATETIME        NULL,
    [Salesperson]  VARCHAR (50)    NULL,
    [CustomerCode] VARCHAR (12)    NULL,
    [Source]       VARCHAR (20)    NULL,
    [TotalValue]   DECIMAL (19, 2) NULL,
    [InvoiceNo]    VARCHAR (12)    NULL,
    [ConvertType]  VARCHAR (2)     NULL,
    [TaxCode]      TINYINT         NULL,
    [SiteNo]       TINYINT         NULL,
    [QuoteRef]     VARCHAR (255)   NULL,
    [InvCustCode]  VARCHAR (12)    NULL,
    [InStoreMemo]  VARCHAR (8000)  NULL,
    [OrderStatus]  VARCHAR (50)    NULL,
    [PoNo]         VARCHAR (255)   NULL,
    [PoValue]      DECIMAL (19, 2) NULL
) ON [PRIMARY];


GO
-- Header/detail join key
CREATE NONCLUSTERED INDEX [ix_quotations_quoteno]
    ON [raw_ccdata].[Quotations]([QuoteNo])
    INCLUDE([CustomerCode], [Salesperson]);