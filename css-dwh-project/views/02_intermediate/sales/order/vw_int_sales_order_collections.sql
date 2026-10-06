CREATE
-- OR ALTER
VIEW [int].[sales_order_collections] AS
SELECT
    order_number,
    employee_key
FROM (
    SELECT
        e.id_code AS order_number,
        e.employee_key,
        ROW_NUMBER() OVER (
            PARTITION BY e.id_code
            ORDER BY e.event_id DESC
        ) AS rn
    FROM
        [stg].[events] AS e
    WHERE
        e.event_type = '17010'
) AS ranked
WHERE
    rn = 1