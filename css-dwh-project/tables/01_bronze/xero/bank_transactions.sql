CREATE TABLE [raw_xero].[BankTransactions] (
    [BankTransactionID] NVARCHAR (MAX)   NULL,
    [Type]              NVARCHAR (MAX)   NULL, -- SPEND/RECEIVE (+ -OVERPAYMENT/-PREPAYMENT/-TRANSFER variants)
    [ContactID]         NVARCHAR (MAX)   NULL,
    [ContactName]       NVARCHAR (MAX)   NULL,
    [BankAccountCode]   NVARCHAR (MAX)   NULL,
    [BankAccountName]   NVARCHAR (MAX)   NULL,
    [Date]              NVARCHAR (MAX)   NULL, -- Xero DateString, plain ISO date text (see fn_ParseXeroEpochDate note on Invoices)
    [Reference]         NVARCHAR (MAX)   NULL,
    [CurrencyCode]      NVARCHAR (MAX)   NULL,
    [CurrencyRate]      DECIMAL (38, 18) NULL,
    [SubTotal]          DECIMAL (38, 18) NULL,
    [TotalTax]          DECIMAL (38, 18) NULL,
    [Total]             DECIMAL (38, 18) NULL,
    [Status]            NVARCHAR (MAX)   NULL,
    [UpdatedDateUTC]    NVARCHAR (MAX)   NULL, -- Xero epoch string, e.g. /Date(1770121767397+0000)/
    [LineItems]         NVARCHAR (MAX)   NULL -- raw JSON array of line item objects
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];