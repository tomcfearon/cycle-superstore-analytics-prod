CREATE VIEW [stg].[category_map_temp]
AS
SELECT
    UPPER(LTRIM(RTRIM(ISNULL(CAST([ParentName] AS VARCHAR(100)), '')))) AS [old_category],
    UPPER(LTRIM(RTRIM(ISNULL(CAST([ChildName] AS VARCHAR(100)), ''))))  AS [old_subcategory],
    LTRIM(RTRIM([Category]))                                            AS [new_category],
    LTRIM(RTRIM([Subcategory]))                                         AS [new_subcategory]
FROM [raw_ccdata].[Category_Map];
GO