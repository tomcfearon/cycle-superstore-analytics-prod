CREATE TABLE [marts].[fct_service_engineer_performance]
(
    [activity_date] [date] NOT NULL,
    [engineer_key] [int] NOT NULL,
    -- Persist the ERP bike build metrics at daily engineer grain for semantic reporting.
    [bike_build_count] [int] NOT NULL,
    [bike_build_time_spent] [decimal](18, 2) NOT NULL,
    [floor_bike_build_count] [int] NOT NULL,
    [floor_bike_build_time_spent] [decimal](18, 2) NOT NULL,
    [repair_time_spent] [decimal](18, 2) NOT NULL
) ON [PRIMARY]
GO

-- Cluster by engineer and date to support report filters over date ranges and engineer selections.
CREATE CLUSTERED INDEX [marts_fct_service_engineer_performance_ci]
ON [marts].[fct_service_engineer_performance] ([engineer_key], [activity_date])
GO
