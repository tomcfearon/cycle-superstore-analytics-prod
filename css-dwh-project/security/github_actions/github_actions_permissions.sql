IF NOT EXISTS (
	SELECT 1
	FROM sys.database_role_members AS drm
	INNER JOIN sys.database_principals AS roles
		ON roles.principal_id = drm.role_principal_id
	INNER JOIN sys.database_principals AS members
		ON members.principal_id = drm.member_principal_id
	WHERE roles.name = 'db_owner'
	  AND members.name = 'github-actions-css-dwh'
)
ALTER ROLE db_owner ADD MEMBER [github-actions-css-dwh];
GO
