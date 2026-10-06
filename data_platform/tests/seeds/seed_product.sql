SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse fixture writes outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52140, 'Product seed refused: the current database is not css-dwh-test.', 1;
    END

-- Require the product-domain raw tables to be empty before seeding deterministic fixtures.
IF EXISTS (SELECT 1
       FROM   [raw_ccdata].[Makes])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[Products])
   OR EXISTS (SELECT 1
              FROM   [raw_css2].[categories_products])
   OR EXISTS (SELECT 1
              FROM   [raw_css2].[ItemGroupings_T])
   OR EXISTS (SELECT 1
              FROM   [raw_css2].[ProductOptions_T])
   OR EXISTS (SELECT 1
              FROM   [raw_css2].[products])
   OR EXISTS (SELECT 1
              FROM   [raw_css2].[SortByRelevance])
    BEGIN
        THROW 52141, 'Product seed refused: fixture tables are not empty. Run reset_test_database.sql first.', 1;
    END

BEGIN TRANSACTION;

-- Seed the product hierarchy using the DACPAC-seeded category map.
INSERT  INTO [raw_ccdata].[Makes] (
    [Make],
    [WebAddress],
    [Active],
    [SupplierName]
)
VALUES                           ('Test Brand', 'https://example.invalid/test-brand', 1, 'TEST-SUPPLIER');

INSERT  INTO [raw_ccdata].[Products] (
    [ModelNo],
    [Make],
    [StockDesc],
    [RetailPrice],
    [CostPrice],
    [SupplierCode],
    [GroupId],
    [GroupId2],
    [ItemType],
    [Web],
    [Status],
    [row_modified_datetime]
)
VALUES                              ('TEST-PROD-1', 'Test Brand', 'Synthetic product', 120.00, 60.00, 'TEST-SUPPLIER', 'Accessories(bmx)', 'Acc(bmx) Parts/Acc', 2, 'Yes', 'Active', '2026-01-15T12:00:00');

-- Seed the web parent grouping before its linked web product records.
INSERT  INTO [raw_css2].[ItemGroupings_T] (
    [item_group_id],
    [link],
    [BrandName],
    [idCategory],
    [product_type],
    [details],
    [LastRefreshed]
)
VALUES                                   (800001, N'https://example.invalid/products/test-prod-1', N'Test Brand', 700001, N'Parts', N'Synthetic web product grouping', '2026-01-15T12:00:00');

INSERT  INTO [raw_css2].[products] (
    [idProduct],
    [description],
    [sku],
    [price],
    [listPrice],
    [stock],
    [active],
    [pcprod_ParentPrd],
    [pcprod_EnteredOn]
)
VALUES                            (900001, N'Synthetic web product', N'TEST-PROD-1', 120.00, 120.00, 5, 1, 800001, '2026-01-15T12:00:00');

INSERT  INTO [raw_css2].[categories_products] (
    [idProduct],
    [idCategory],
    [POrder]
)
VALUES                                       (900001, 700001, 1);

INSERT  INTO [raw_css2].[ProductOptions_T] (
    [idProduct],
    [color],
    [size],
    [LastRefreshed]
)
VALUES                                    (900001, N'Black', N'M', '2026-01-15T12:00:00');

INSERT  INTO [raw_css2].[SortByRelevance] (
    [ItemGroupID],
    [RelevancePoints],
    [SalesPoints],
    [TotalSales],
    [InStoreQty],
    [SupplierQty],
    [LastRefreshedOn]
)
VALUES                                   (800001, 10, 5, 1, 5, 0, '2026-01-15T12:00:00');

-- Verify each product-domain raw table contains exactly one fixture record before commit.
IF (SELECT COUNT(*)
    FROM   [raw_ccdata].[Makes]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[Products]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_css2].[categories_products]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_css2].[ItemGroupings_T]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_css2].[ProductOptions_T]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_css2].[products]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_css2].[SortByRelevance]) <> 1
    BEGIN
        THROW 52142, 'Product seed failed: fixture row counts do not match the one-row contract.', 1;
    END

COMMIT TRANSACTION;

PRINT 'Synthetic product fixture seeded successfully.';