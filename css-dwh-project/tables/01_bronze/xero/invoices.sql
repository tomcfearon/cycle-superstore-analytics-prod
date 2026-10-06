CREATE TABLE [raw_xero].[Invoices] (
    [InvoiceID]      NVARCHAR (MAX) NULL,
    [InvoiceNumber]  NVARCHAR (MAX) NULL,
    [Reference]      NVARCHAR (MAX) NULL,
    [Type]           NVARCHAR (MAX) NULL,
    [Status]         NVARCHAR (MAX) NULL,
    [InvoiceDate]    NVARCHAR (MAX) NULL, -- Xero epoch string, e.g. /Date(1518685950940+0000)/
    [DueDate]        NVARCHAR (MAX) NULL, -- Xero epoch string
    [SubTotal]       FLOAT          NULL,
    [TotalTax]       FLOAT          NULL,
    [Total]          FLOAT          NULL,
    [AmountDue]      FLOAT          NULL,
    [AmountPaid]     FLOAT          NULL,
    [AmountCredited] FLOAT          NULL,
    [CurrencyCode]   NVARCHAR (MAX) NULL,
    [CurrencyRate]   FLOAT          NULL,
    [UpdatedDateUTC] NVARCHAR (MAX) NULL, -- Xero epoch string
    [ContactID]      NVARCHAR (MAX) NULL,
    [ContactName]    NVARCHAR (MAX) NULL,
    [LineItems]      NVARCHAR (MAX) NULL -- raw JSON array of line item objects
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
