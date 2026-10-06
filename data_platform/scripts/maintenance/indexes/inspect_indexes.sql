SELECT   s.name AS schema_name,
         t.name AS table_name,
         i.name AS index_name,
         i.type_desc AS index_type,
         i.is_primary_key,
         i.is_unique,
         STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS indexed_columns
FROM     sys.indexes AS i
         INNER JOIN
         sys.tables AS t
         ON i.object_id = t.object_id
         INNER JOIN
         sys.schemas AS s
         ON t.schema_id = s.schema_id
         INNER JOIN
         sys.index_columns AS ic
         ON i.object_id = ic.object_id
            AND i.index_id = ic.index_id
         INNER JOIN
         sys.columns AS c
         ON ic.object_id = c.object_id
            AND ic.column_id = c.column_id
WHERE    ic.is_included_column = 0
GROUP BY s.name, t.name, i.name, i.type_desc, i.is_primary_key, i.is_unique
ORDER BY s.name, t.name, i.name;