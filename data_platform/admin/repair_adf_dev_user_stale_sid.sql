-- One-time repair: the Dev ADF managed identity was regenerated at some point after the
-- database user was first created, so [df-css-ana-dev-neu] is bound to a dead SID
-- (717b2603-98f8-49e4-be4c-394f6550e5c0) instead of the ADF's current identity
-- (a89d5184-a067-48cf-a6fb-fea889cbf38d, confirmed live via Azure Resource Graph).
-- adf_user.sql can never fix this on its own because its guard checks by name, not SID.
--
-- Run this once against css-dwh-dev, then re-publish the DACPAC (or run
-- security/adf/adf_user.sql and security/adf/adf_permissions.sql manually) to
-- recreate the user against the correct identity and reapply its grants.

-- Review before running: confirms which principal is being removed and its stale SID.
SELECT name, type_desc, authentication_type_desc, CONVERT(uniqueidentifier, sid) AS current_sid
FROM sys.database_principals
WHERE name = 'df-css-ana-dev-neu';

DROP USER IF EXISTS [df-css-ana-dev-neu];
