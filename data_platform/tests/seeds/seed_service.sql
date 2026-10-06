SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse fixture writes outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52170, 'Service seed refused: the current database is not css-dwh-test.', 1;
    END

-- Require the service-domain raw tables to be empty before seeding deterministic fixtures.
IF EXISTS (SELECT 1
           FROM   [raw_ccdata].[Repairs])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[RepairsDetails])
    BEGIN
        THROW 52171, 'Service seed refused: fixture tables are not empty. Run reset_test_database.sql first.', 1;
    END

BEGIN TRANSACTION;

-- Seed the service header before its linked service detail.
INSERT  INTO [raw_ccdata].[Repairs] (
    [FaultNo],
    [Faultdate],
    [RepairDate],
    [DateCompleted],
    [CustomerCode],
    [InvoiceNo],
    [InvoiceDate],
    [Salesperson],
    [Engineer],
    [Source],
    [CurrentStatus],
    [StockCode],
    [RepairType],
    [TotalCost],
    [TotalLabour],
    [TotalParts],
    [VATCharge],
    [TotalCharge],
    [SiteNo],
    [TransType],
    [row_modified_datetime]
)
VALUES                             ('TST-SRV-1', '2026-01-13T00:00:00', '2026-01-14T00:00:00', '2026-01-15T00:00:00', 'TEST-CUST-1', 'TST-SRV-INV', '2026-01-15T00:00:00', 'Test Employee', 'Test Employee', 'TEST', 'Completed', 'TEST-STOCK-1', 'Service', 60.00, 30.00, 20.00, 10.00, 60.00, 1, 3, '2026-01-15T12:00:00');

INSERT  INTO [raw_ccdata].[RepairsDetails] (
    [FaultNo],
    [StockCode],
    [Description],
    [Qty],
    [CostPrice],
    [SellPrice],
    [GroupSeqNo],
    [SiteNo],
    [StockLocation],
    [Credited],
    [ItemType],
    [StockPrice],
    [row_modified_datetime]
)
VALUES                                    ('TST-SRV-1', 'TEST-STOCK-1', 'Synthetic service line', 1, 20.00, 30.0000, 1, 1, 'TEST-STORE', 0, 2, 30.00, '2026-01-15T12:00:00');

-- Verify each service-domain raw table contains exactly one fixture record before commit.
IF (SELECT COUNT(*)
    FROM   [raw_ccdata].[Repairs]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[RepairsDetails]) <> 1
    BEGIN
        THROW 52172, 'Service seed failed: fixture row counts do not match the one-row contract.', 1;
    END

COMMIT TRANSACTION;

PRINT 'Synthetic service fixture seeded successfully.';

SELECT [transaction_key],
       [order_number],
       [customer_code],
       [salesperson_key],
       [engineer_key],
       [product_key],
       [quantity],
       [price],
       [vat_amount],
       [price_before_discount],
       [cost],
       [invoice_date],
       [repair_date],
       [completion_date],
       [invoice_status],
       [is_faulty],
       [is_credited],
       [line_sequence_number],
       [order_channel]
FROM   [marts].[fct_service_invoices]
WHERE  [transaction_key] = 'SVC-INV-TST-SRV-INV';