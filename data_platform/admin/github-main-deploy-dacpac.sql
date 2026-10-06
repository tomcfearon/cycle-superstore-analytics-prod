CREATE USER [github-actions-css-dwh] FOR EXTERNAL PROVIDER;

ALTER ROLE db_owner ADD MEMBER [github-actions-css-dwh];