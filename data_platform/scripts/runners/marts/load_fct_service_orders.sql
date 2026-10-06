SET NOCOUNT ON;

DECLARE @t0 AS DATETIME2 (3) = SYSDATETIME();

EXECUTE [marts].[usp_load_fct_service_orders] @ForceFullLoad = 1;

SELECT DATEDIFF(ms, @t0, SYSDATETIME()) AS duration_ms;