SET NOCOUNT ON;

DECLARE @t0 DATETIME2(3) = SYSDATETIME();

EXEC [marts].[usp_load_fct_purchase_orders];

SELECT DATEDIFF(ms, @t0, SYSDATETIME()) AS duration_ms;
