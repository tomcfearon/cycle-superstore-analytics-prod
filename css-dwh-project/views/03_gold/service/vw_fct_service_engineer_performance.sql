CREATE
-- OR ALTER
VIEW [marts].[vw_fct_service_engineer_performance] AS
-- Pass through the engineer-day performance fact so marts stays aligned to the ERP-derived intermediate logic.
SELECT
    activity_date,
    engineer_key,
    bike_build_count,
    bike_build_time_spent,
    floor_bike_build_count,
    floor_bike_build_time_spent,
    repair_time_spent
FROM
    [int].[service_engineer_performance];
