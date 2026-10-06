CREATE
-- OR ALTER
VIEW stg.exchange_emails AS
SELECT
    [receivedDateTime] AS received_date_time,
    [subject],
    [bodyPreview] AS body_preview,
    [name],
    [address],
    [ingested_time],
    [source_mailbox_upn],
    [conversation_id],
    [conversation_index],
    [webLink] AS web_link,
    [body_text]
FROM
    [raw_365].[365_mail];