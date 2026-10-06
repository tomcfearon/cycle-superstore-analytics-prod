CREATE TABLE [raw_ccdata].[SundryHeader] (
    [TransType]             TINYINT         NULL,
    [InvoiceNo]             VARCHAR (12)    NULL,
    [OpenInvoice]           TINYINT         NULL,
    [InvoiceDate]           DATETIME        NULL,
    [Salesperson]           VARCHAR (50)    NULL,
    [CustomerCode]          VARCHAR (12)    NULL,
    [TotalValue]            DECIMAL (19, 2) NULL,
    [PaymentToDate]         DECIMAL (19, 2) NULL,
    [DiscountToDate]        DECIMAL (19, 2) NULL,
    [WriteOffToDate]        DECIMAL (19, 2) NULL,
    [PayCompleteDate]       DATETIME        NULL,
    [TaxRate1]              DECIMAL (4, 2)  NULL,
    [GoodsValue1]           DECIMAL (19, 2) NULL,
    [TaxValue1]             DECIMAL (19, 2) NULL,
    [TaxRate2]              DECIMAL (4, 2)  NULL,
    [GoodsValue2]           DECIMAL (19, 2) NULL,
    [TaxValue2]             DECIMAL (19, 2) NULL,
    [TaxRate3]              DECIMAL (4, 2)  NULL,
    [GoodsValue3]           DECIMAL (19, 2) NULL,
    [TaxValue3]             DECIMAL (19, 2) NULL,
    [TaxRate4]              DECIMAL (4, 2)  NULL,
    [GoodsValue4]           DECIMAL (19, 2) NULL,
    [TaxValue4]             DECIMAL (19, 2) NULL,
    [TaxRate5]              DECIMAL (4, 2)  NULL,
    [GoodsValue5]           DECIMAL (19, 2) NULL,
    [TaxValue5]             DECIMAL (19, 2) NULL,
    [SiteNo]                TINYINT         NULL,
    [row_modified_datetime] DATETIME        NULL
) ON [PRIMARY];


GO
-- Supports the header/detail join, same pattern as InvoiceHeader
CREATE NONCLUSTERED INDEX [ix_sundry_header_transtype_invoiceno]
    ON [raw_ccdata].[SundryHeader]([TransType], [InvoiceNo])
    INCLUDE([Salesperson], [CustomerCode]);