CREATE VIEW -- OR ALTER
[int].[vw_int_bizimply_timecards_daily]
AS
WITH   weekly
AS     (SELECT employee_number AS bizimply_ref_numb,
               department,
               base_pay_rate,
               total_paid_hours,
               -- payroll data covers the Mon-Sun week preceding the Monday morning it's ingested
               DATEADD(DAY, -7, DATEADD(DAY, -(DATEDIFF(DAY, 0, CAST (ingested_time AS DATE)) % 7), CAST (ingested_time AS DATE))) AS week_start_date,
               monday_hours,
               tuesday_hours,
               wednesday_hours,
               thursday_hours,
               friday_hours,
               saturday_hours,
               sunday_hours
        FROM   [stg].[vw_stg_bizimply_timecards])
SELECT w.bizimply_ref_numb,
       e.employee_key,
       w.department,
       w.week_start_date,
       DATEADD(DAY, d.day_offset, w.week_start_date) AS shift_date,
       d.hours,
       w.base_pay_rate,
       w.total_paid_hours * w.base_pay_rate AS paid_amount_per_week,
       CASE WHEN e.employee_key IS NULL THEN 1 ELSE 0 END AS is_employee_unmatched
FROM   weekly AS w CROSS APPLY (VALUES (0, w.monday_hours), (1, w.tuesday_hours), (2, w.wednesday_hours), (3, w.thursday_hours), (4, w.friday_hours), (5, w.saturday_hours), (6, w.sunday_hours)) AS d(day_offset, hours)
       LEFT OUTER JOIN
       [stg].[employees] AS e
       ON TRIM(e.employee_reference_number) = TRIM(w.bizimply_ref_numb);