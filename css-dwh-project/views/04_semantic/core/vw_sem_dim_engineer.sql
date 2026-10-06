CREATE
-- OR ALTER
VIEW [dbo].[48 - Engineer] AS

/*
    Role-playing dimension — Employee viewed as Engineer.
    Rename employee_key → engineer_key so Power BI can create a separate
    relationship from fact tables' [engineer_key] column without conflicting
    with the base Employee dimension.
*/

SELECT
    [employee_key]              AS [Engineer Key],
    [customer_code]             AS [Customer Code],
    [employee_name]             AS [Engineer Name],
    [is_active]                 AS [Is Active],
     [bonus]                    AS [Bonus],
    [start_date]                AS [Start Date],
    [employee_reference_number] AS [Engineer Reference Number]
FROM [marts].[dim_employee];
