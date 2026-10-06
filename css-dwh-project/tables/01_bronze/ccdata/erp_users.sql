CREATE TABLE [raw_ccdata].[AdminUsers] (
    [UserID]               INT            NULL,
    [UserName]             NVARCHAR (50)  NULL,
    [Password]             NVARCHAR (255) NULL,
    [Active]               INT            NULL,
    [Bonus]                FLOAT          NULL,
    [Note]                 VARCHAR (MAX)  NULL,
    [StartDate]            DATETIME       NULL,
    [SwipeCard]            VARCHAR (10)   NULL,
    [SaleTarget]           INT            NULL,
    [CustomerCode]         VARCHAR (50)   NULL,
    [Engineer]             BIT            NULL,
    [EmpRefNo]             VARCHAR (50)   NULL,
    [BonusCollected]       FLOAT          NULL,
    [UseAllStockLocations] BIT            NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
-- Employee join key
CREATE NONCLUSTERED INDEX [ix_admin_users_userid]
    ON [raw_ccdata].[AdminUsers]([UserID]);