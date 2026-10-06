CREATE
-- OR ALTER
VIEW [marts].[vw_fct_exchange_emails_with_customer] AS
SELECT
    CAST(TRY_CAST(received_date_time AS datetime2(3)) AS date) AS received_date,
    subject,
    body_preview,
    name,
    address,
    ingested_time,
    source_mailbox_upn,
    conversation_id,
    conversation_index,
    web_link,
    body_text,
    customer_code
FROM
    [int].[exchange_emails_with_customer];