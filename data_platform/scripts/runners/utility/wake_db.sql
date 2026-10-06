-- Minimal query used by CI/CD to trigger resume of a paused Azure SQL
-- serverless database. azure/sql-action runs this with continue-on-error: true;
-- even if it fails, the connection attempt wakes the database.
SELECT 1 AS alive;

