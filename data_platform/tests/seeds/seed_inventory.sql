SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse fixture writes outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52130, 'Inventory seed refused: the current database is not css-dwh-test.', 1;
    END

-- Require the inventory-domain raw tables to be empty before seeding deterministic fixtures.
IF EXISTS (SELECT 1
           FROM   [raw_ccdata].[Inventory])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[Stock])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[StockCountedLocations])
    BEGIN
        THROW 52131, 'Inventory seed refused: fixture tables are not empty. Run reset_test_database.sql first.', 1;
    END

BEGIN TRANSACTION;

-- Seed stock before its location balance and inventory snapshot records.
INSERT  INTO [raw_ccdata].[Stock] (
    [StockCode],
    [ItemType],
    [StockDesc],
    [MakeID],
    [ModelNo],
    [RetailPrice],
    [CostPrice],
    [StockLocation],
    [Status],
    [SiteNo],
    [row_modified_datetime]
)
VALUES                           ('TEST-STOCK-1', 2, 'Synthetic inventory item', 'Test Brand', 'TEST-PROD-1', 120.00, 60.00, 'TEST-STORE', 'Active', 1, '2026-01-15T12:00:00');

-- Seed the stock-location balance for the inventory stock record.
INSERT  INTO [raw_ccdata].[StockCountedLocations] (
    [StockCode],
    [StockLocation],
    [QtyOnHand],
    [QtyOnOrder],
    [QtyReserved],
    [DateCounted],
    [BinNo]
)
VALUES                                           ('TEST-STOCK-1', 'TEST-STORE', 5, 1, 1, '2026-01-15T12:00:00', 'TEST-BIN-1');

-- Seed the warehouse inventory snapshot aligned with the product-key convention.
INSERT  INTO [raw_ccdata].[Inventory] (
    [stock_key],
    [quantity_on_hand_t1],
    [quantity_on_hand_t2],
    [quantity_on_hand_cara],
    [query_datetime],
    [query_date]
)
VALUES                               ('TEST-STOCK-1-0', 3, 1, 1, '2026-01-15T12:00:00', '2026-01-15');

-- Verify each inventory-domain raw table contains exactly one fixture record before commit.
IF (SELECT COUNT(*)
    FROM   [raw_ccdata].[Stock]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[StockCountedLocations]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[Inventory]) <> 1
    BEGIN
        THROW 52132, 'Inventory seed failed: fixture row counts do not match the one-row contract.', 1;
    END

COMMIT TRANSACTION;

PRINT 'Synthetic inventory fixture seeded successfully.';