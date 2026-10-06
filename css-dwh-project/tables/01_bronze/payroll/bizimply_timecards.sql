CREATE TABLE [raw_payroll].[bizimply_timecards] (
    [Bizimply Unique ID] NVARCHAR (MAX) NULL,
    [First Name]         NVARCHAR (MAX) NULL,
    [Last Name]          NVARCHAR (MAX) NULL,
    [Employee Number]    NVARCHAR (MAX) NULL,
    [Department]         NVARCHAR (MAX) NULL,
    [Monday]             NVARCHAR (MAX) NULL,
    [Tuesday]            NVARCHAR (MAX) NULL,
    [Wednesday]          NVARCHAR (MAX) NULL,
    [Thursday]           NVARCHAR (MAX) NULL,
    [Friday]             NVARCHAR (MAX) NULL,
    [Saturday]           NVARCHAR (MAX) NULL,
    [Sunday]             NVARCHAR (MAX) NULL,
    [Total Regular]      NVARCHAR (MAX) NULL,
    [Total Sunday]       NVARCHAR (MAX) NULL,
    [Total Paid Hours]   NVARCHAR (MAX) NULL,
    [Base Pay Rate]      NVARCHAR (MAX) NULL,
    [Column6]            NVARCHAR (MAX) NULL, -- source CSV has an unnamed/blank header between Base Pay Rate and Paid Time Off
    [Paid Time Off]      NVARCHAR (MAX) NULL,
    [Paid Sick]          NVARCHAR (MAX) NULL,
    [Cash Extras 1]      NVARCHAR (MAX) NULL,
    [ingested_time]      DATETIME2 (3)  NULL
) ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_bizimply_timecards_ingested_time]
    ON [raw_payroll].[bizimply_timecards]([ingested_time])
    INCLUDE([Employee Number]);