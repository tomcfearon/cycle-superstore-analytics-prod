CREATE TABLE [raw_ccdata].[Makes] (
    [Make]                   VARCHAR (50)   NULL,
    [WebAddress]             VARCHAR (255)  NULL,
    [Target Markup Main RRP] DECIMAL (4, 2) NULL,
    [Target Markup Sun RRP]  DECIMAL (4, 2) NULL,
    [Distribution]           BIT            NULL,
    [Active]                 BIT            NULL,
    [Notes]                  VARCHAR (8000) NULL,
    [WinterForwardOrderDate] DATETIME       NULL,
    [SummerForwardOrderDate] DATETIME       NULL,
    [LastPurchasedDate]      DATETIME       NULL,
    [LastReviewDate]         DATETIME       NULL,
    [NextReviewDate]         DATETIME       NULL,
    [SupplierName]           VARCHAR (50)   NULL,
    [BonusVoucherExclude]    BIT            NULL,
    [TargetMarginMain]       DECIMAL (4, 2) NULL,
    [TargetMarginSundry]     DECIMAL (4, 2) NULL
) ON [PRIMARY];