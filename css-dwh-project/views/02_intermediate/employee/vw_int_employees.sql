CREATE
-- OR ALTER
VIEW [int].[employees] AS
SELECT
    e.employee_key,
    e.employee_name,
    e.is_active,
    e.employee_reference_number,
    e.start_date,
    e.customer_code,
    e.is_engineer,
    ISNULL(ROUND(e.bonus / 100.0, 4), 0) AS bonus,
    ISNULL(ROUND(e.bonus_from_collections /100 , 4), 0) AS bonus_from_collections
FROM
    [stg].[employees] AS e
UNION
ALL
SELECT
    -1 AS employee_key,
    'Shop' AS employee_name,
    0 AS is_active,
    NULL AS employee_reference_number,
    CAST(NULL AS datetime) AS start_date,
    CAST(NULL AS varchar(255)) AS customer_code,
    0 AS is_engineer,
    CAST(NULL AS float) AS bonus,
    CAST(NULL AS float) AS bonus_from_collections;