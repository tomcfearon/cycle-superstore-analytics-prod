SELECT name AS database_name,
       is_auto_create_stats_on, -- 1 = Enabled (Default)
       is_auto_update_stats_on, -- 1 = Enabled (Default)
       is_auto_update_stats_async_on -- 0 = Synchronous (Standard), 1 = Async
FROM   sys.databases
WHERE  name = DB_NAME();