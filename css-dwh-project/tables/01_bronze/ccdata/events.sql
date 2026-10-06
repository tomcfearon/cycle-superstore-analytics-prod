CREATE TABLE [raw_ccdata].[Events] (
    [EventID]     INT            NULL,
    [EventType]   INT            NULL,
    [EventStatus] INT            NULL,
    [IDCode]      NVARCHAR (255) NULL,
    [StartDate]   DATETIME       NULL,
    [EndDate]     DATETIME       NULL,
    [SalesPerson] INT            NULL,
    [Urgent]      INT            NULL,
    [Event_Data1] NVARCHAR (MAX) NULL,
    [Event_Data2] NVARCHAR (255) NULL,
    [Event_Data3] NVARCHAR (255) NULL,
    [Event_Data4] NVARCHAR (255) NULL,
    [Event_Data5] NVARCHAR (255) NULL,
    [Event_Data6] NVARCHAR (255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];