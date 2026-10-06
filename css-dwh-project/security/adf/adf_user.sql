-- Test DACPAC publishes skip ADF principals because ADF does not load the isolated test database.
IF '$(DeployAdfSecurity)' = 'True'
   AND NOT EXISTS (SELECT 1
                   FROM   sys.database_principals
                   WHERE  name = '$(AdfPrincipalName)')
    BEGIN
        CREATE USER [$(AdfPrincipalName)] FOR EXTERNAL PROVIDER;
    END


GO
--
-- 2. Ensure Dev ADF user exists on Prod (so it can pull snapshots from Prod).
-- Skipped on Dev because $(AdfPrincipalName) already resolves to df-css-ana-dev-neu above.
IF '$(DeployAdfSecurity)' = 'True'
   AND '$(AdfPrincipalName)' <> 'df-css-ana-dev-neu'
    BEGIN
        -- Keep the Dev principal idempotent on Prod; recreate only via an intentional repair path.
        IF NOT EXISTS (SELECT 1
                       FROM   sys.database_principals
                       WHERE  name = 'df-css-ana-dev-neu')
            EXECUTE ('CREATE USER [df-css-ana-dev-neu] FROM EXTERNAL PROVIDER');
    END