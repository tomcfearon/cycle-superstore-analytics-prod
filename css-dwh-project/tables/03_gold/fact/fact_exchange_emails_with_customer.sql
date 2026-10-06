CREATE TABLE [marts].[fct_exchange_emails_with_customer] (
    [received_date] [date] NULL,
    [subject] [nvarchar](max) NULL,
    [body_preview] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [address] [nvarchar](max) NULL,
    [ingested_time] [datetime2](3) NULL,
    [source_mailbox_upn] [nvarchar](320) NULL,
    [conversation_id] [nvarchar](512) NULL,
    [conversation_index] [nvarchar](max) NULL,
    [web_link] [nvarchar](2048) NULL,
    [body_text] [nvarchar](max) NULL,
    [customer_code] [varchar](12) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [marts_fct_exchange_emails_with_customer_ci]
ON [marts].[fct_exchange_emails_with_customer] ([received_date], [customer_code]) ON [PRIMARY]
GO
