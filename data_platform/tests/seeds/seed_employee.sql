SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse fixture writes outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52120, 'Employee seed refused: the current database is not css-dwh-test.', 1;
    END

-- Require the employee-domain raw table to be empty before seeding a deterministic fixture.
IF EXISTS (SELECT 1
           FROM   [raw_ccdata].[AdminUsers])
    BEGIN
        THROW 52121, 'Employee seed refused: fixture table is not empty. Run reset_test_database.sql first.', 1;
    END

BEGIN TRANSACTION;

-- Seed the salesperson and service engineer referenced by transactional fixtures.
INSERT  INTO [raw_ccdata].[AdminUsers] (
    [UserID],
    [UserName],
    [Active],
    [Bonus],
    [StartDate],
    [CustomerCode],
    [Engineer],
    [EmpRefNo],
    [BonusCollected],
    [UseAllStockLocations]
)
VALUES                                (900001, N'Test Employee', 1, 0, '2026-01-01T00:00:00', 'TEST-CUST-1', 1, 'TEST-EMP-1', 0, 1);

-- Verify the employee-domain raw table contains exactly one fixture record before commit.
IF (SELECT COUNT(*)
    FROM   [raw_ccdata].[AdminUsers]) <> 1
    BEGIN
        THROW 52122, 'Employee seed failed: fixture row count does not match the one-row contract.', 1;
    END

COMMIT TRANSACTION;

PRINT 'Synthetic employee fixture seeded successfully.';