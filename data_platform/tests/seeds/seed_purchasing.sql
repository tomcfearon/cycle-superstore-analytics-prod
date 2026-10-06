SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse fixture writes outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52150, 'Purchasing seed refused: the current database is not css-dwh-test.', 1;
    END

-- Require the purchasing-domain raw tables to be empty before seeding deterministic fixtures.
IF EXISTS (SELECT 1
           FROM   [raw_ccdata].[PurchaseOrderHeader])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[PurchaseOrderDetails])
    BEGIN
        THROW 52151, 'Purchasing seed refused: fixture tables are not empty. Run reset_test_database.sql first.', 1;
    END

BEGIN TRANSACTION;

-- Seed the purchase-order header before the linked order detail.
INSERT  INTO [raw_ccdata].[PurchaseOrderHeader] (
    [OrderNo],
    [Salesperson],
    [SupplierCode],
    [OrderDate],
    [DueIn],
    [OrderRef],
    [SiteNo],
    [TransType],
    [GoodsInDate]
)
VALUES                                         ('TST-PO-1', 'Test Employee', 'TEST-SUPPLIER', '2026-01-10T00:00:00', '2026-01-20T00:00:00', 'Synthetic purchase order', 1, 1, '2026-01-15T00:00:00');

INSERT  INTO [raw_ccdata].[PurchaseOrderDetails] (
    [OrderNo],
    [Qty],
    [Cost],
    [QtyReceived],
    [SeqNo],
    [ItemType],
    [ModelNo],
    [StockLocation],
    [Make],
    [Description],
    [SiteNo],
    [BookedDate],
    [RetailPrice]
)
VALUES                                          ('TST-PO-1', 2, 60.000, 1, 1, 2, 'TEST-PROD-1', 'TEST-STORE', 'Test Brand', 'Synthetic purchase order line', 1, '2026-01-10T00:00:00', 120.000);

-- Verify each purchasing-domain raw table contains exactly one fixture record before commit.
IF (SELECT COUNT(*)
    FROM   [raw_ccdata].[PurchaseOrderHeader]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[PurchaseOrderDetails]) <> 1
    BEGIN
        THROW 52152, 'Purchasing seed failed: fixture row counts do not match the one-row contract.', 1;
    END

COMMIT TRANSACTION;

PRINT 'Synthetic purchasing fixture seeded successfully.';