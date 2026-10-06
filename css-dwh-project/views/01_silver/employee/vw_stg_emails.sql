CREATE VIEW --OR ALTER
[stg].[emails]
AS
SELECT [receivedDateTime] AS recieved_utc,
       [subject] AS email_subject,
       [name] AS emailer_name,
       [address] AS sender_address,
       [source_mailbox_upn] AS received_address,
       [conversation_id] AS thread_id,
       [message_id] AS email_id,
       [webLink] AS email_link,
       [body_content_type],
       [body_text]
FROM   [raw_365].[365_mail];