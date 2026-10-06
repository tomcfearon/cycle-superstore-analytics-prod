CREATE
-- OR ALTER
VIEW [int].[customers] AS
WITH cleaned_phones AS (
        SELECT
            customer_code,
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(trim(nullif(phone_number, '')), ' ', ''),
                                '+',
                                ''
                            ),
                            '(',
                            ''
                        ),
                        ')',
                        ''
                    ),
                    '-',
                    ''
                ),
                '/',
                ''
            ) AS customer_phone_number
        FROM
            [stg].[customer_numbers]
        WHERE
            phone_type <> 'FAX'
    ),
    length_filtered AS (
        SELECT
            customer_code,
            customer_phone_number
        FROM
            cleaned_phones
        WHERE
            customer_phone_number IS NOT NULL
            AND len(customer_phone_number) BETWEEN 7
            AND 15
    ),
    phone_per_customer AS (
        SELECT
            customer_code,
            min(customer_phone_number) AS customer_phone_number
        FROM
            length_filtered
        GROUP BY
            customer_code
    )
SELECT
    c.customer_type,
    c.price_band,
    c.is_on_stop,
    cast(c.account_opened_date AS date) AS account_opened_date,
    cast(c.last_in_store_date AS date) AS last_in_store_date,
    c.credit_balance,
    nullif(trim(c.customer_code), '') AS customer_code,
    CASE
        WHEN nullif(trim(c.first_name), '') IS NOT NULL
        AND nullif(trim(c.last_name), '') IS NOT NULL THEN trim(c.first_name) + ' ' + trim(c.last_name)
        WHEN nullif(trim(c.first_name), '') IS NOT NULL THEN trim(c.first_name)
        WHEN nullif(trim(c.last_name), '') IS NOT NULL THEN trim(c.last_name)
    END AS customer_name,
    nullif(trim(c.company_name), '') AS company_name,
    isnull(c.gender, 0) AS gender,
    isnull(c.credit_terms, 0) AS credit_terms,
    isnull(c.credit_limit, 0) AS credit_limit,
    nullif(
        REPLACE(
            REPLACE(
                lower(trim(c.email_address)),
                ' ',
                ''
            ),
            char(9),
            ''
        ),
        ''
    ) AS email_address,
    nullif(
        REPLACE(
            REPLACE(
                lower(trim(cpn.customer_phone_number)),
                ' ',
                ''
            ),
            char(9),
            ''
        ),
        ''
    ) AS phone_number,
    CASE
        WHEN c.is_archived IS NULL THEN 0
        WHEN try_cast(c.is_archived AS int) = 0 THEN 0
        ELSE c.is_archived
    END AS is_archived,
    c.row_modified_datetime -- ERP-stamped datetime passed through from stg.customers
FROM
    stg.customers AS c
    LEFT JOIN (
        SELECT
            customer_code,
            min(customer_phone_number) AS customer_phone_number
        FROM
            length_filtered
        GROUP BY
            customer_code
    ) AS cpn ON c.customer_code = cpn.customer_code;
