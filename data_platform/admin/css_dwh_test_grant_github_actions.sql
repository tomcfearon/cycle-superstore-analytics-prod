-- Bootstrap the existing GitHub OIDC principal before its first css-dwh-test DACPAC publish.
IF DB_NAME() <> N'css-dwh-test'
BEGIN
    RAISERROR ('Bootstrap refused: the current database is not css-dwh-test.', 16, 1);
    RETURN;
END;
GO

-- Create the external database principal idempotently using the existing Entra application.
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'github-actions-css-dwh'
)
BEGIN
    CREATE USER [github-actions-css-dwh] FROM EXTERNAL PROVIDER;
END;
GO

-- Match the current DACPAC deployment permission model used by GitHub Actions.
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members AS role_members
    INNER JOIN sys.database_principals AS roles
        ON roles.principal_id = role_members.role_principal_id
    INNER JOIN sys.database_principals AS members
        ON members.principal_id = role_members.member_principal_id
    WHERE roles.name = N'db_owner'
      AND members.name = N'github-actions-css-dwh'
)
BEGIN
    ALTER ROLE [db_owner] ADD MEMBER [github-actions-css-dwh];
END;
GO