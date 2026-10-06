-- Ensure the GitHub Actions deployment user exists on every DACPAC publish.
-- Unlike ADF (system-assigned MI), this is an app registration with a stable OID,
-- so DROP + recreate is NOT used — dropping the currently-connected user
-- mid-deployment revokes its database access and breaks the post-deploy script.
IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals WHERE name = 'github-actions-css-dwh'
)
BEGIN
    EXEC('CREATE USER [github-actions-css-dwh] FROM EXTERNAL PROVIDER');
END;
GO
