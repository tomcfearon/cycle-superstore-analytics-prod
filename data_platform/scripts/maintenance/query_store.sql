SELECT actual_state_desc,
       readonly_reason,
       current_storage_size_mb,
       max_storage_size_mb
FROM   sys.database_query_store_options;