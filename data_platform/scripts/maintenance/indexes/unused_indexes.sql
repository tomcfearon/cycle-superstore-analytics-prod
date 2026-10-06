SELECT   s.name AS schema_name,
         t.name AS table_name,
         i.name AS index_name,
         us.user_seeks + us.user_scans + us.user_lookups AS total_reads,
         us.user_updates AS total_writes
FROM     sys.dm_db_index_usage_stats AS us
         INNER JOIN
         sys.indexes AS i
         ON us.object_id = i.object_id
            AND us.index_id = i.index_id
         INNER JOIN
         sys.tables AS t
         ON i.object_id = t.object_id
         INNER JOIN
         sys.schemas AS s
         ON t.schema_id = s.schema_id
WHERE    us.database_id = DB_ID()
         AND i.is_primary_key = 0
         AND (us.user_seeks + us.user_scans + us.user_lookups) = 0
ORDER BY us.user_updates DESC;