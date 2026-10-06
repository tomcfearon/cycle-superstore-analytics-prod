CREATE PROCEDURE -- OR ALTER 
[dbo].[usp_drop_if_full_load]
@FullTableName NVARCHAR (255), @IsIncremental BIT -- e.g., 'dbo.InvoiceHeader'
AS
BEGIN
    SET NOCOUNT ON;
    -- If incremental, do nothing and exit
    IF @IsIncremental = 1
        RETURN;
    -- Extract table name and swap 'dbo' for 'raw_ccdata'
    DECLARE @RawTableName AS NVARCHAR (255) = REPLACE(@FullTableName, 'dbo.', '');
    DECLARE @DropSql AS NVARCHAR (MAX) = N'IF OBJECT_ID(''[raw_ccdata].[' + @RawTableName + ']'', ''U'') IS NOT NULL DROP TABLE [raw_ccdata].[' + @RawTableName + '];';
    EXECUTE sp_executesql @DropSql;
END