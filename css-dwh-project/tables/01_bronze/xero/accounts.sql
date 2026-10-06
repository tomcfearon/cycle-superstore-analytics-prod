CREATE TABLE [raw_xero].[Accounts] (
    [AccountID]      NVARCHAR (MAX) NULL,
    [Code]           NVARCHAR (MAX) NULL,
    [Name]           NVARCHAR (MAX) NULL,
    [Type]           NVARCHAR (MAX) NULL, -- e.g. BANK, CURRENT, EXPENSE, REVENUE
    [Class]          NVARCHAR (MAX) NULL, -- e.g. ASSET, EQUITY, EXPENSE, LIABILITY, REVENUE
    [Status]         NVARCHAR (MAX) NULL,
    [UpdatedDateUTC] NVARCHAR (MAX) NULL -- Xero epoch string
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
