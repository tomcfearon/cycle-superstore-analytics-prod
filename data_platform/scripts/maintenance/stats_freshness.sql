SELECT   s.name AS schema_name,
         t.name AS table_name,
         st.name AS stat_name,
         sp.last_updated,
         sp.rows AS total_rows,
         sp.rows_sampled,
         sp.modification_counter AS rows_modified_since_last_stat_update,
         ROUND(CAST (sp.modification_counter AS FLOAT) / NULLIF (sp.rows, 0) * 100, 2) AS pct_modified
FROM     sys.stats AS st
         INNER JOIN
         sys.tables AS t
         ON st.object_id = t.object_id
         INNER JOIN
         sys.schemas AS s
         ON t.schema_id = s.schema_id CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp
ORDER BY sp.modification_counter DESC;