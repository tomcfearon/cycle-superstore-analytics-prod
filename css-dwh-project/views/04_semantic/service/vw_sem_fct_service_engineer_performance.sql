CREATE
-- OR ALTER
VIEW [dbo].[16 - Service Engineer Performance]
AS
SELECT [activity_date] AS [Activity Date],
       [engineer_key] AS [Engineer Key],
       -- Expose the ERP engineer performance metrics directly for the semantic layer.
       [bike_build_count] AS [Bike Builds],
       [bike_build_time_spent] AS [Bike Build Time],
       [floor_bike_build_count] AS [Floor Bike Builds],
       [floor_bike_build_time_spent] AS [Floor Bike Build Time],
       [repair_time_spent] AS [Repair Time Spent]
FROM   [marts].[fct_service_engineer_performance];