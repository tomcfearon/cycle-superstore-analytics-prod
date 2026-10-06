SELECT 
    name AS database_name,
    is_read_committed_snapshot_on, -- 1 = Enabled (Azure SQL Default)
    snapshot_isolation_state_desc  -- 'OFF' or 'ON'
FROM sys.databases
WHERE name = DB_NAME();