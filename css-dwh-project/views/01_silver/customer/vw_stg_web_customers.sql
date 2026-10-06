CREATE
-- OR ALTER
VIEW [stg].[web_customers] AS
WITH base AS (
        SELECT
            [idcustomer] AS customer_id,
            [ERCode] AS cp_connection,
            [name] AS first_name,
            [lastName] AS last_name,
            [customerCompany] AS company,
            [phone] AS phone,
            [email] AS email,
            [address] AS address_line_1,
            [address2] AS address_line_2,
            [zip] AS postal_code,
            [stateCode] AS state_code,
            [state] AS state,
            [city] AS city,
            [countryCode] AS country_code,
            [customerType] AS customer_type,
            [pcCust_DateCreated] AS created_at,
            lower(ltrim(rtrim([email]))) AS email_normalized
        FROM
            [raw_css2].[customers]
    ),
    ranked AS (
        SELECT
            b.*,
            row_number() over (
                PARTITION by b.email_normalized
                ORDER BY
                    b.customer_id DESC
            ) AS rn
        FROM
            base b
        WHERE
            b.email_normalized IS NOT NULL
            AND b.email_normalized <> ''
    ),
    dedup AS (
        -- keep all rows with NULL/blank email (cannot dedupe those by email),
        -- plus exactly 1 row per nonblank email (largest customer_id wins)
        SELECT
            *
        FROM
            base
        WHERE
            email_normalized IS NULL
            OR email_normalized = ''
        UNION
        ALL
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
            email_normalized
        FROM
            ranked
        WHERE
            rn = 1
    )
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
    created_at
FROM
    dedup;

;
