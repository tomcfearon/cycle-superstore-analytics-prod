-- Test DACPAC publishes skip ADF permissions because ADF does not load the isolated test database.
IF '$(DeployAdfSecurity)' = 'True'
    BEGIN
        -- Grant the environment ADF identity its loader permissions idempotently.
        IF NOT EXISTS (SELECT 1
                       FROM   sys.database_role_members AS drm
                              INNER JOIN
                              sys.database_principals AS roles
                              ON roles.principal_id = drm.role_principal_id
                              INNER JOIN
                              sys.database_principals AS members
                              ON members.principal_id = drm.member_principal_id
                       WHERE  roles.name = 'db_datareader'
                              AND members.name = '$(AdfPrincipalName)')
            BEGIN
                ALTER ROLE db_datareader ADD MEMBER [$(AdfPrincipalName)];
            END
        IF NOT EXISTS (SELECT 1
                       FROM   sys.database_role_members AS drm
                              INNER JOIN
                              sys.database_principals AS roles
                              ON roles.principal_id = drm.role_principal_id
                              INNER JOIN
                              sys.database_principals AS members
                              ON members.principal_id = drm.member_principal_id
                       WHERE  roles.name = 'db_datawriter'
                              AND members.name = '$(AdfPrincipalName)')
            BEGIN
                ALTER ROLE db_datawriter ADD MEMBER [$(AdfPrincipalName)];
            END
        GRANT EXECUTE TO [$(AdfPrincipalName)];
        GRANT CREATE TABLE TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::raw_365 TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::raw_xero TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::raw_google TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::raw_css2 TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::raw_ccdata TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::raw_payroll TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::marts TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::meta TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::dbo TO [$(AdfPrincipalName)];
        GRANT ALTER
            ON SCHEMA::int TO [$(AdfPrincipalName)];
        -- Production also grants the Dev ADF identity read access for approved snapshots.
        IF '$(AdfPrincipalName)' <> 'df-css-ana-dev-neu'
           AND NOT EXISTS (SELECT 1
                           FROM   sys.database_role_members AS drm
                                  INNER JOIN
                                  sys.database_principals AS roles
                                  ON roles.principal_id = drm.role_principal_id
                                  INNER JOIN
                                  sys.database_principals AS members
                                  ON members.principal_id = drm.member_principal_id
                           WHERE  roles.name = 'db_datareader'
                                  AND members.name = 'df-css-ana-dev-neu')
            BEGIN
                ALTER ROLE db_datareader ADD MEMBER [df-css-ana-dev-neu];
            END
    END