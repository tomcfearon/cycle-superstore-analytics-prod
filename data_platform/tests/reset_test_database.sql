SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse destructive cleanup outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52100, 'Reset refused: the current database is not css-dwh-test.', 1;
    END

DECLARE @schema_name AS sysname;

DECLARE @table_name AS sysname;

DECLARE @truncate_sql AS NVARCHAR (776);

-- Clear loader-managed tables while preserving DACPAC-seeded reference data and metadata.
DECLARE table_cursor CURSOR LOCAL FAST_FORWARD
    FOR SELECT   schemas.name,
                 tables.name
        FROM     sys.tables AS tables
                 INNER JOIN
                 sys.schemas AS schemas
                 ON schemas.schema_id = tables.schema_id
        WHERE    schemas.name IN (N'raw_365', N'raw_ccdata', N'raw_css2', N'raw_google', N'int', N'marts', N'meta')
                 AND NOT (schemas.name = N'raw_ccdata'
                          AND tables.name = N'Category_Map')
                 AND NOT (schemas.name = N'marts'
                          AND tables.name = N'dim_order_channel')
        ORDER BY CASE schemas.name WHEN N'marts' THEN 1 WHEN N'int' THEN 2 ELSE 3 END, schemas.name, tables.name;

OPEN table_cursor;

FETCH NEXT FROM table_cursor INTO @schema_name, @table_name;

WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @truncate_sql = N'TRUNCATE TABLE ' + QUOTENAME(@schema_name) + N'.' + QUOTENAME(@table_name) + N';';
        EXECUTE sys.sp_executesql @truncate_sql;
        FETCH NEXT FROM table_cursor INTO @schema_name, @table_name;
    END

CLOSE table_cursor;

DEALLOCATE table_cursor;

PRINT 'css-dwh-test loader-managed tables reset successfully.';


-- DROP VIEW IF EXISTS int.service_product; -- Replace SomeTable with the actual table name you want to drop