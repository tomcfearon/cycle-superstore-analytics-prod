SET NOCOUNT ON;

DECLARE @t0 datetime2(3) = SYSDATETIME();

EXEC [marts].[usp_load_fct_used_bikes_memo];

SELECT DATEDIFF(ms, @t0, SYSDATETIME()) AS duration_ms;


  Select used_bike_id,
  count(*) as count
  from [marts].[fct_used_bikes_memo]
  GROUP BY used_bike_id
  HAVING count(*) > 1
