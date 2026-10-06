CREATE VIEW -- OR ALTER
[stg].[xero_accounts]
AS
WITH   deduped
AS     (SELECT AccountID,
               Code,
               Name,
               [Type],
               Class,
               [Status],
               UpdatedDateUTC,
               ROW_NUMBER() OVER (PARTITION BY AccountID ORDER BY dbo.fn_ParseXeroEpochDate(UpdatedDateUTC) DESC) AS rn
        FROM   raw_xero.Accounts)
SELECT AccountID AS account_id,
       Code AS account_code,
       Name AS account_name,
       [Type] AS account_type,
       Class AS account_class,
       [Status] AS [status],
       dbo.fn_ParseXeroEpochDate(UpdatedDateUTC) AS updated_date_utc
FROM   deduped
WHERE  rn = 1;