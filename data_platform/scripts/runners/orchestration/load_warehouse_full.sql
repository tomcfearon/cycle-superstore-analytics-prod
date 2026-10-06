SET NOCOUNT ON;

DECLARE @t0 datetime2(3) = SYSDATETIME();

EXEC [dbo].[usp_load_warehouse_full];

SELECT DATEDIFF(ms, @t0, SYSDATETIME()) AS duration_ms;
