/*
--------------------------------------------------------------------------------------
 POST-DEPLOYMENT SCRIPT
 Master entry point compiled into the DACPAC.
 Executes sequentially after schema changes are applied.
--------------------------------------------------------------------------------------
*/
PRINT 'Executing Post-Deployment scripts...';

-- 1. Reference Data Seeds
PRINT 'Seeding reference data...';
:r .\seeds\raw_ccdata_category_map.sql

-- 2. Security & Environment Permissions
PRINT 'Applying Entra ID security principals & permissions...';
:r .\security\github_actions\github_actions_user.sql
:r .\security\github_actions\github_actions_permissions.sql
:r .\security\adf\adf_user.sql
:r .\security\adf\adf_permissions.sql

-- 3. Deployment Audit Logging
PRINT 'Logging deployment to [meta].[deployment_log]...';

IF OBJECT_ID(N'[meta].[deployment_log]', N'U') IS NOT NULL
BEGIN
    INSERT INTO [meta].[deployment_log] ([deployment_notes])
    VALUES ('DACPAC Post-Deployment Execution');

    PRINT 'Deployment logged successfully.';
END
ELSE
BEGIN
    PRINT 'Warning: [meta].[deployment_log] table not found; skipped logging.';
END;
GO
