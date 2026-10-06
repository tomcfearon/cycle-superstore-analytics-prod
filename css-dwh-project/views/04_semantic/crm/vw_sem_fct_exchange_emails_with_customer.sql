CREATE
-- OR ALTER
VIEW [dbo].[11 - Emails] AS
SELECT
    [received_date]      AS [Received Date],
    [subject]                 AS [Subject],
    [body_preview]            AS [Body Preview],
    [name]                    AS [Name],
    [address]                 AS [Address],
    [ingested_time]           AS [Ingested Time],
    [source_mailbox_upn]      AS [Source Mailbox Upn],
    [conversation_id]         AS [Conversation ID],
    [conversation_index]      AS [Conversation Index],
    [web_link]                AS [Web Link],
    [body_text]               AS [Body Text],
    [customer_code]           AS [Customer Code]
FROM [marts].[fct_exchange_emails_with_customer]