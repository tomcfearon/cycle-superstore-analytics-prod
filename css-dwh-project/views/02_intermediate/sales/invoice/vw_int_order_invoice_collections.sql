CREATE
-- OR ALTER
VIEW [int].[order_invoice_collections] AS
SELECT
    invoice_number,
    employee_key
FROM (
    SELECT
        e.id_code AS invoice_number,
        e.employee_key,
        ROW_NUMBER() OVER (
            PARTITION BY e.id_code
            ORDER BY e.event_id DESC
        ) AS rn
    FROM
        [stg].[events] AS e
    WHERE
        e.event_type = '29010'
) AS ranked
WHERE
    rn = 1