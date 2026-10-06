CREATE VIEW [marts].[vw_dim_xero_account]
AS
SELECT account_code,
       account_name,
       account_type,
       account_class
FROM   [stg].[xero_accounts];