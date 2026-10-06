CREATE
-- OR ALTER
VIEW [marts].[vw_dim_employee] AS
SELECT
    e.employee_key,
    e.customer_code,
    dbo.fn_TitleCase(e.employee_name) AS employee_name,
    cast(e.is_active AS bit) AS is_active,
    cast(e.is_engineer AS bit) AS is_engineer,
    cast(e.start_date AS date) AS start_date,
    e.bonus,
    e.bonus_from_collections,
    e.employee_reference_number
FROM
    [int].[employees] AS e