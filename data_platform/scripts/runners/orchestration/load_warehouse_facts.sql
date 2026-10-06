SET NOCOUNT ON;

DECLARE @t0 datetime2(3) = SYSDATETIME();

EXEC [marts].[usp_load_warehouse_facts];

SELECT DATEDIFF(ms, @t0, SYSDATETIME()) AS duration_ms;
