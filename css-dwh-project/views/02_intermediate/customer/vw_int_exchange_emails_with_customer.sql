CREATE
-- OR ALTER
VIEW [int].[exchange_emails_with_customer] AS
WITH emails AS (
    SELECT
        received_date_time,
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
        LOWER(REPLACE(LTRIM(RTRIM(address)), ' ', '')) AS address_email_normalized
    FROM
        [stg].[exchange_emails]
)
SELECT
    e.received_date_time,
    e.subject,
    e.body_preview,
    e.name,
    e.address,
    e.ingested_time,
    e.source_mailbox_upn,
    e.conversation_id,
    e.conversation_index,
    e.web_link,
    e.body_text,
    cc.customer_code
FROM
    emails AS e
    LEFT JOIN [int].[consolidated_customers] AS cc ON cc.email_normalized = e.address_email_normalized;