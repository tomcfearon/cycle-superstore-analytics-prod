CREATE VIEW -- OR ALTER
[stg].[vw_stg_bizimply_timecards]
AS
SELECT [Bizimply Unique ID] AS bizimply_unique_id,
       [First Name] AS first_name,
       [Last Name] AS last_name,
       [Employee Number] AS employee_number,
       [Department] AS department,
       TRY_CAST ([Monday] AS DECIMAL (10, 2)) AS monday_hours,
       TRY_CAST ([Tuesday] AS DECIMAL (10, 2)) AS tuesday_hours,
       TRY_CAST ([Wednesday] AS DECIMAL (10, 2)) AS wednesday_hours,
       TRY_CAST ([Thursday] AS DECIMAL (10, 2)) AS thursday_hours,
       TRY_CAST ([Friday] AS DECIMAL (10, 2)) AS friday_hours,
       TRY_CAST ([Saturday] AS DECIMAL (10, 2)) AS saturday_hours,
       TRY_CAST ([Sunday] AS DECIMAL (10, 2)) AS sunday_hours,
       TRY_CAST ([Total Regular] AS DECIMAL (10, 2)) AS total_regular_hours,
       TRY_CAST ([Total Sunday] AS DECIMAL (10, 2)) AS total_sunday_hours,
       TRY_CAST ([Total Paid Hours] AS DECIMAL (10, 2)) AS total_paid_hours,
       TRY_CAST ([Base Pay Rate] AS DECIMAL (10, 2)) AS base_pay_rate,
       TRY_CAST ([Paid Time Off] AS DECIMAL (10, 2)) AS paid_time_off_hours,
       TRY_CAST ([Paid Sick] AS DECIMAL (10, 2)) AS paid_sick_hours,
       TRY_CAST ([Cash Extras 1] AS DECIMAL (10, 2)) AS cash_extras_1,
       ingested_time
FROM   [raw_payroll].[bizimply_timecards]
WHERE  [Bizimply Unique ID] <> 'Totals'; -- the Bizimply export appends a non-employee totals row per file