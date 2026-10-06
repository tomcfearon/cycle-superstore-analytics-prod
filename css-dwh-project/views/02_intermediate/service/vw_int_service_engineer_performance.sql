CREATE VIEW -- OR ALTER
[int].[service_engineer_performance]
AS
WITH-- Dedupe employees by name to prevent LEFT JOIN fan-out (see vw_int_fact_repair_lines.sql).
         deduped_employees
AS       (SELECT employee_key,
                 employee_name,
                 ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
          FROM   [int].[employees]),
         event_activity
AS       (-- Aggregate ERP bike build events by day and engineer using the historical SO/SI/SER versus floor split.
          SELECT   CAST (e.start_date AS DATE) AS activity_date,
                   ISNULL(TRY_CONVERT (INT, e.employee_key), -1) AS engineer_key,
                   SUM(CASE WHEN UPPER(LTRIM(RTRIM(ISNULL(e.event_data_1, '')))) IN ('SO', 'SI', 'SER') THEN 1 ELSE 0 END) AS bike_build_count,
                   SUM(CASE WHEN UPPER(LTRIM(RTRIM(ISNULL(e.event_data_1, '')))) IN ('SO', 'SI', 'SER')
                                 AND COALESCE (TRY_CONVERT (DECIMAL (18, 2), e.event_data_4), 0) > 0 THEN TRY_CONVERT (DECIMAL (18, 2), e.event_data_4) ELSE 0 END) AS bike_build_time_spent,
                   SUM(CASE WHEN UPPER(LTRIM(RTRIM(ISNULL(e.event_data_1, '')))) IN ('SO', 'SI', 'SER') THEN 0 ELSE 1 END) AS floor_bike_build_count,
                   SUM(CASE WHEN UPPER(LTRIM(RTRIM(ISNULL(e.event_data_1, '')))) IN ('SO', 'SI', 'SER') THEN 0 WHEN COALESCE (TRY_CONVERT (DECIMAL (18, 2), e.event_data_4), 0) > 0 THEN TRY_CONVERT (DECIMAL (18, 2), e.event_data_4) ELSE 0 END) AS floor_bike_build_time_spent,
                   CAST (0 AS DECIMAL (18, 2)) AS repair_time_spent
          FROM     [stg].[events] AS e
          WHERE    TRY_CONVERT (INT, e.event_type) = 1
                   AND e.start_date IS NOT NULL
          GROUP BY CAST (e.start_date AS DATE), ISNULL(TRY_CONVERT (INT, e.employee_key), -1)),
         repair_activity
AS       (-- Aggregate repair time by invoice date and route blank or unmatched engineers to the synthetic Shop member.
          SELECT   CAST (h.invoice_date AS DATE) AS activity_date,
                   CASE WHEN NULLIF (LTRIM(RTRIM(h.engineer_name)), '') IS NULL THEN -1 WHEN eng.employee_key IS NULL THEN -1 ELSE eng.employee_key END AS engineer_key, -- Blank repair engineers should reconcile to Shop.
           -- Unmatched nonblank engineers also roll to the synthetic Shop member.
                   CAST (0 AS INT) AS bike_build_count,
                   CAST (0 AS DECIMAL (18, 2)) AS bike_build_time_spent,
                   CAST (0 AS INT) AS floor_bike_build_count,
                   CAST (0 AS DECIMAL (18, 2)) AS floor_bike_build_time_spent,
                   SUM(CASE WHEN COALESCE (TRY_CONVERT (DECIMAL (18, 2), h.repair_time), 0) > 0 THEN TRY_CONVERT (DECIMAL (18, 2), h.repair_time) ELSE 0 END) AS repair_time_spent
          FROM     [int].[base_repair_headers] AS h
                   LEFT OUTER JOIN
                   deduped_employees AS eng
                   ON h.engineer_name = eng.employee_name
                      AND eng.rn = 1
          WHERE    h.invoice_date IS NOT NULL
          GROUP BY CAST (h.invoice_date AS DATE), CASE WHEN NULLIF (LTRIM(RTRIM(h.engineer_name)), '') IS NULL THEN -1 WHEN eng.employee_key IS NULL THEN -1 ELSE eng.employee_key END),
         combined_activity
AS       (-- Stack event and repair contributions before rolling them into one engineer-day fact row.
          SELECT activity_date,
                 engineer_key,
                 bike_build_count,
                 bike_build_time_spent,
                 floor_bike_build_count,
                 floor_bike_build_time_spent,
                 repair_time_spent
          FROM   event_activity
          UNION ALL
          SELECT activity_date,
                 engineer_key,
                 bike_build_count,
                 bike_build_time_spent,
                 floor_bike_build_count,
                 floor_bike_build_time_spent,
                 repair_time_spent
          FROM   repair_activity)
SELECT   -- Return one row per engineer per day with the legacy ERP engineer-performance metrics already pivoted.
         activity_date,
         engineer_key,
         SUM(bike_build_count) AS bike_build_count,
         SUM(bike_build_time_spent) AS bike_build_time_spent,
         SUM(floor_bike_build_count) AS floor_bike_build_count,
         SUM(floor_bike_build_time_spent) AS floor_bike_build_time_spent,
         SUM(repair_time_spent) AS repair_time_spent
FROM     combined_activity
GROUP BY activity_date, engineer_key;