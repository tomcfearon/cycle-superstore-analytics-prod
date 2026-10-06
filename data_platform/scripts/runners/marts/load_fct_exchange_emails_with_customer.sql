SET NOCOUNT ON;

DECLARE @t0 datetime2(3) = SYSDATETIME();

EXEC [marts].[usp_load_fct_exchange_emails_with_customer];

SELECT DATEDIFF(ms, @t0, SYSDATETIME()) AS duration_ms;
