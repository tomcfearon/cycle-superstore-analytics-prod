CREATE
-- OR ALTER
VIEW [int].[product_google_signals]
AS
    WITH latest_benchmark AS
    (
        SELECT
            product_key,
            benchmark_price,
            NULLIF(TRIM(CONCAT_WS(' > ',
                NULLIF(category_l1, ''),
                NULLIF(category_l2, ''),
                NULLIF(category_l3, ''),
                NULLIF(category_l4, ''),
                NULLIF(category_l5, '')
            )), '') AS google_category,
            ROW_NUMBER() OVER (
                PARTITION BY product_key
                ORDER BY partition_date DESC
            ) AS rn
        FROM [stg].[google_price_competitiveness]
    ),
    latest_suggested AS
    (
        SELECT
            product_key,
            suggested_price,
            NULLIF(TRIM(CONCAT_WS(' > ',
                NULLIF(category_l1, ''),
                NULLIF(category_l2, ''),
                NULLIF(category_l3, ''),
                NULLIF(category_l4, ''),
                NULLIF(category_l5, '')
            )), '') AS google_category,
            ROW_NUMBER() OVER (
                PARTITION BY product_key
                ORDER BY partition_date DESC
            ) AS rn
        FROM [stg].[google_price_insights]
    )
    SELECT
        COALESCE(lb.product_key, ls.product_key) AS product_id_key,
        lb.benchmark_price,
        ls.suggested_price,
        COALESCE(lb.google_category, ls.google_category) AS google_category
    FROM
    (
        SELECT
            product_key,
            benchmark_price,
            google_category
        FROM latest_benchmark
        WHERE rn = 1
    ) AS lb
        FULL OUTER JOIN
    (
        SELECT
            product_key,
            suggested_price,
            google_category
        FROM latest_suggested
        WHERE rn = 1
    ) AS ls
            ON lb.product_key = ls.product_key;