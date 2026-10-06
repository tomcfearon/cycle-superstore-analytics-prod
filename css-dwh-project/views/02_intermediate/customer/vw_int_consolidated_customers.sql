CREATE
-- OR ALTER
VIEW [int].[consolidated_customers] AS
WITH web_customers AS (
    SELECT
        customer_id,
        cp_connection,
        first_name,
        last_name,
        company,
        phone,
        email,
        address_line_1,
        address_line_2,
        postal_code,
        state_code,
        state,
        city,
        country_code,
        customer_type,
        created_at,
        LOWER(REPLACE(LTRIM(RTRIM(email)), ' ', '')) AS email_normalized
    FROM
        [stg].[web_customers]
),
web_customers_dedup AS (
    SELECT
        *
    FROM
        (
            SELECT
                w.*,
                ROW_NUMBER() OVER (
                    PARTITION BY w.email_normalized
                    ORDER BY
                        w.created_at DESC,
                        -- newest web account wins
                        w.customer_id DESC -- tie-breaker
                ) AS rn
            FROM
                web_customers AS w
            WHERE
                w.email_normalized IS NOT NULL
                AND w.email_normalized LIKE '%@%.%' -- only dedupe / keep for legit-looking emails
        ) AS x
    WHERE
        x.rn = 1
),
store_customers AS (
    SELECT
        customer_type,
        price_band,
        is_on_stop,
        account_opened_date,
        last_in_store_date,
        credit_balance,
        customer_code,
        customer_name,
        company_name,
        gender,
        credit_terms,
        credit_limit,
        email_address,
        phone_number,
        is_archived,
        row_modified_datetime, -- ERP-stamped datetime passed through from int.customers
        LOWER(REPLACE(LTRIM(RTRIM(email_address)), ' ', '')) AS email_normalized
    FROM
        [int].[customers]
    WHERE
        customer_code IS NOT NULL
),
joined AS (
    SELECT
        c.customer_code,
        -- store (no prefix)
        c.customer_name,
        c.company_name,
        c.phone_number,
        c.customer_type,
        c.price_band,
        c.is_on_stop,
        CASE
            WHEN w.created_at > c.account_opened_date THEN w.created_at
            ELSE c.account_opened_date
        END AS account_opened_date,
        c.last_in_store_date,
        c.credit_balance,
        c.gender,
        c.credit_terms,
        c.credit_limit,
        c.is_archived,
        c.row_modified_datetime, -- passed through from store customer source
        -- web (prefixed)
        w.customer_id AS web_customer_id,
        w.cp_connection AS web_cp_connection,
        w.first_name AS web_first_name,
        w.last_name AS web_last_name,
        w.company AS web_company,
        w.phone AS web_phone,
        w.address_line_1 AS web_address_line_1,
        w.address_line_2 AS web_address_line_2,
        CASE
            WHEN w.postal_code IS NULL THEN NULL
            ELSE CASE
                WHEN LEN(LTRIM(RTRIM(w.postal_code))) <= 20 THEN LTRIM(RTRIM(w.postal_code))
                ELSE NULL
            END
        END AS web_postal_code,
        w.state_code AS web_state_code,
        w.state AS web_state,
        w.city AS web_city,
        w.country_code AS web_country_code,
        w.customer_type AS web_customer_type,
        w.created_at AS web_created_at,
        -- normalized email chosen from either side
        COALESCE(w.email_normalized, c.email_normalized) AS email_normalized
    FROM
        store_customers AS c
        LEFT JOIN web_customers_dedup AS w ON c.email_normalized = w.email_normalized
),
email_scored AS (
    SELECT
        j.*,
        CASE
            WHEN j.email_normalized LIKE '%@%.%' THEN 1
            ELSE 0
        END AS is_valid_email,
        ROW_NUMBER() OVER (
            PARTITION BY CASE
                WHEN j.email_normalized LIKE '%@%.%' THEN j.email_normalized
            END
            ORDER BY
                ISNULL(j.row_modified_datetime, j.account_opened_date) DESC,
                j.customer_code DESC
        ) AS email_rn
    FROM
        joined AS j
)
SELECT
    customer_code,
    customer_name,
    company_name,
    phone_number,
    customer_type,
    price_band,
    is_on_stop,
    account_opened_date,
    last_in_store_date,
    credit_balance,
    gender,
    credit_terms,
    credit_limit,
    is_archived,
    row_modified_datetime, -- ERP-stamped datetime from store customer source
    web_customer_id,
    web_cp_connection,
    web_first_name,
    web_last_name,
    web_company,
    web_phone,
    web_address_line_1,
    web_address_line_2,
    web_postal_code,
    web_state_code,
    web_state,
    web_city,
    web_country_code,
    web_customer_type,
    web_created_at,
    CASE
        WHEN is_valid_email = 1
        AND email_rn = 1 THEN email_normalized
        ELSE NULL
    END AS email,
    email_normalized,
    -- Retail vs. Trade classification
    CASE
        WHEN LOWER(customer_type) = 'trade' THEN 'Trade'
        ELSE 'Retail'
    END AS retail_trade
FROM
    email_scored;
