CREATE TABLE [meta].[refresh_metadata] (
    [table_name]       VARCHAR(200) NOT NULL,
    [layer_name]       VARCHAR(50)  NOT NULL,
    [refresh]          INT          NOT NULL CONSTRAINT [DF_refresh_metadata_refresh] DEFAULT 0,
    [last_refresh_utc] DATETIME2(3) NOT NULL,
    CONSTRAINT [PK_refresh_metadata] PRIMARY KEY CLUSTERED ([table_name] ASC)
);
GO
