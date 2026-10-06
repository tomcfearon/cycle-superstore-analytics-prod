SET NOCOUNT ON;

DECLARE @t0 AS DATETIME2 (3) = SYSDATETIME();

EXECUTE [int].[usp_load_web_stock_integrated] ;

SELECT DATEDIFF(ms, @t0, SYSDATETIME()) AS duration_ms;


GO
SELECT TOP 100 *
FROM   [int].[vw_int_web_stock_integrated];