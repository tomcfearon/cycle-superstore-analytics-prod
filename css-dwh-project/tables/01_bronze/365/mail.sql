CREATE TABLE [raw_365].[365_mail] (
    [receivedDateTime]   NVARCHAR (MAX)  NULL,
    [subject]            NVARCHAR (MAX)  NULL,
    [bodyPreview]        NVARCHAR (MAX)  NULL,
    [name]               NVARCHAR (MAX)  NULL,
    [address]            NVARCHAR (MAX)  NULL,
    [ingested_time]      DATETIME2 (3)   NULL,
    [source_mailbox_upn] NVARCHAR (320)  NULL,
    [conversation_id]    NVARCHAR (512)  NULL,
    [message_id]         NVARCHAR (512)  NULL,
    [conversation_index] NVARCHAR (MAX)  NULL,
    [webLink]            NVARCHAR (2048) NULL,
    [body_content_type]  NVARCHAR (20)   NULL,
    [body_content]       NVARCHAR (MAX)  NULL,
    [body_text]          NVARCHAR (MAX)  NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_365_mail_ingested_time]
    ON [raw_365].[365_mail]([ingested_time])
    INCLUDE([source_mailbox_upn], [conversation_id], [webLink]) WHERE [ingested_time] IS NOT NULL;


GO
CREATE NONCLUSTERED INDEX [IX_365_mail_conversation_id]
    ON [raw_365].[365_mail]([conversation_id])
    INCLUDE([ingested_time], [source_mailbox_upn]) WHERE [conversation_id] IS NOT NULL;
