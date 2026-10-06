SELECT   ROUND(s.avg_total_user_cost * (s.avg_user_impact / 100.0) * (s.user_seeks + s.user_scans), 2) AS impact_score,
         s.avg_user_impact AS estimated_cost_reduction_pct,
         d.statement AS target_table,
         d.equality_columns,
         d.inequality_columns,
         d.included_columns
FROM     sys.dm_db_missing_index_group_stats AS s
         INNER JOIN
         sys.dm_db_missing_index_groups AS g
         ON s.group_handle = g.index_group_handle
         INNER JOIN
         sys.dm_db_missing_index_details AS d
         ON g.index_handle = d.index_handle
ORDER BY impact_score DESC;