CREATE
-- OR ALTER
VIEW [dbo].[44 - Employee] AS

/*
    Role-playing dimension — Employee viewed as Salesperson.
    Replaces the retired [44 - Employee] base dimension.
    Rename employee_key → salesperson_key so Power BI can relate fact tables'
    [salesperson_key] column directly.
*/

SELECT
    [employee_key]              AS [Employee Key],
    [customer_code]             AS [Customer Code],
    [employee_name]             AS [Employee Name],
    [is_active]                 AS [Is Active],
    [bonus]                     AS [Bonus],
    [bonus_from_collections] AS [Bonus From Collections],
    [start_date]                AS [Start Date],
    [employee_reference_number] AS [Employee Reference Number]
FROM [marts].[dim_employee];
