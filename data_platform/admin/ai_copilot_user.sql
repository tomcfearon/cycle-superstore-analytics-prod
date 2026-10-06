-- =============================================================================
-- AI Copilot SQL User Provisioning
-- See: .github/instructions/ai_tool_permissions.instructions.md for policy.
--
-- Policy summary:
--   css-dwh-dev  : db_datareader only. All writes require a reviewed manual script.
--   css-dwh-prod : db_datareader only. Writes are physically impossible.
--
-- To enforce: remove the Entra ID profiles from the VS Code MSSQL extension
-- and add this user as a SQL Server Authentication profile instead.
-- Password must be stored in Key Vault — never committed here.
-- =============================================================================
-- -----------------------------------------------------------------------
-- STEP 1: Server-level login (run once on the logical SQL server as admin)
-- -----------------------------------------------------------------------
-- CREATE LOGIN [ai_copilot] WITH PASSWORD = '<retrieve-from-key-vault>';
-- -----------------------------------------------------------------------
-- SECTION A: css-dwh-dev
-- Allowed: SELECT only (db_datareader)
-- All INSERT/UPDATE/DELETE/DROP/ALTER require a reviewed manual script.
-- Run against css-dwh-dev
-- -----------------------------------------------------------------------
CREATE USER [ai_copilot] FOR LOGIN [ai_copilot];

ALTER ROLE db_datareader ADD MEMBER [ai_copilot]; -- read-only; no write grants


-- -----------------------------------------------------------------------
-- SECTION B: css-dwh-prod
-- Allowed: SELECT only — writes are physically impossible for this user
-- Run against css-dwh-prod
-- -----------------------------------------------------------------------
-- CREATE USER [ai_copilot] FOR LOGIN [ai_copilot];
-- ALTER ROLE db_datareader ADD MEMBER [ai_copilot]; -- read-only; no write grants