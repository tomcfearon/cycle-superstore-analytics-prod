SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse fixture writes outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52160, 'Sales seed refused: the current database is not css-dwh-test.', 1;
    END

-- Require the sales-domain raw tables to be empty before seeding deterministic fixtures.
IF EXISTS (SELECT 1
           FROM   [raw_ccdata].[Events])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[InvoiceHeader])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[InvoiceDetails])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[Quotations])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[QuotationDetails])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[SaleOrderHeader])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[SaleOrderDetails])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[SundryHeader])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[SundryDetails])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[UsedBikes])
    BEGIN
        THROW 52161, 'Sales seed refused: fixture tables are not empty. Run reset_test_database.sql first.', 1;
    END

BEGIN TRANSACTION;

-- Seed the order invoice header before its detail and collection event.
INSERT  INTO [raw_ccdata].[InvoiceHeader] (
    [TransType],
    [InvoiceNo],
    [OpenInvoice],
    [InvoiceDate],
    [Salesperson],
    [Source],
    [CustomerCode],
    [TotalValue],
    [OrderDate],
    [DispatchDetails],
    [InStoreMemo],
    [row_modified_datetime]
)
VALUES                                   (1, 'TST-INV-1', 0, '2026-01-15T10:30:00', 'Test Employee', 'TEST', 'TEST-CUST-1', 120.00, '2026-01-14T09:00:00', 1, 'Synthetic order invoice', '2026-01-15T12:00:00');

INSERT  INTO [raw_ccdata].[InvoiceDetails] (
    [TransType],
    [InvoiceNo],
    [StockCode],
    [Price],
    [Qty],
    [VATValue],
    [Cost],
    [Description],
    [GroupSeqNo],
    [Credited],
    [StockPrice],
    [row_modified_datetime]
)
VALUES                                    (1, 'TST-INV-1', 'MISC', 120.00, 2, 20.00, 30.00, 'Synthetic misc invoice line', 1, 0, 60.00, '2026-01-15T12:00:00');

INSERT  INTO [raw_ccdata].[Events] (
    [EventID],
    [EventType],
    [EventStatus],
    [IDCode],
    [StartDate],
    [EndDate],
    [SalesPerson],
    [Urgent],
    [Event_Data1]
)
VALUES                            (910001, 1, 1, N'TST-INV-1', '2026-01-15T10:30:00', '2026-01-15T11:00:00', 900001, 0, N'Synthetic invoice collection event');

-- Seed the quotation header before its line item.
INSERT  INTO [raw_ccdata].[Quotations] (
    [QuoteNo],
    [QuoteDate],
    [Salesperson],
    [CustomerCode],
    [Source],
    [TotalValue],
    [OrderStatus]
)
VALUES                                ('TST-QUO-1', '2026-01-12T00:00:00', 'Test Employee', 'TEST-CUST-1', 'TEST', 120.00, 'Open');

INSERT  INTO [raw_ccdata].[QuotationDetails] (
    [QuoteNo],
    [ModelNo],
    [Make],
    [Price],
    [Qty],
    [ItemType],
    [ItemPrice],
    [GroupSeqNo],
    [Description],
    [SiteNo]
)
VALUES                                      ('TST-QUO-1', 'TEST-PROD-1', 'Test Brand', 120.00, 1, 2, 120.00, 1, 'Synthetic quotation line', 1);

-- Seed the sales-order header before its corresponding detail.
INSERT  INTO [raw_ccdata].[SaleOrderHeader] (
    [TransType],
    [InvoiceNo],
    [OpenInvoice],
    [InvoiceDate],
    [Salesperson],
    [Source],
    [CustomerCode],
    [TotalValue],
    [OrderStatus],
    [SiteNo]
)
VALUES                                     (1, 'TST-SO-1', 1, '2026-01-13T00:00:00', 'Test Employee', 'TEST', 'TEST-CUST-1', 120.00, 'Open', 1);

INSERT  INTO [raw_ccdata].[SaleOrderDetails] (
    [TransType],
    [InvoiceNo],
    [StockCode],
    [Price],
    [Qty],
    [VATValue],
    [Cost],
    [Description],
    [GroupSeqNo],
    [ModelNo],
    [StockPrice],
    [SiteNo]
)
VALUES                                      (1, 'TST-SO-1', 'TEST-STOCK-1', 120.00, 1, 20.00, 60.00, 'Synthetic sales order line', 1, 'TEST-PROD-1', 120.00, 1);

-- Seed the point-of-sale header before its corresponding detail.
INSERT  INTO [raw_ccdata].[SundryHeader] (
    [TransType],
    [InvoiceNo],
    [OpenInvoice],
    [InvoiceDate],
    [Salesperson],
    [CustomerCode],
    [TotalValue],
    [SiteNo],
    [row_modified_datetime]
)
VALUES                                  (1, 'TST-POS-1', 0, '2026-01-15T09:00:00', 'Test Employee', 'TEST-CUST-1', 25.00, 1, '2026-01-15T12:00:00');

INSERT  INTO [raw_ccdata].[SundryDetails] (
    [TransType],
    [InvoiceNo],
    [StockCode],
    [Price],
    [Qty],
    [VATValue],
    [Cost],
    [Description],
    [GroupSeqNo],
    [StockPrice],
    [SiteNo],
    [row_modified_datetime]
)
VALUES                                   (1, 'TST-POS-1', 'TEST-STOCK-1', 25.00, 1, 4.17, 12.00, 'Synthetic till line', 1, 25.00, 1, '2026-01-15T12:00:00');

-- Seed a used-bike record linked to the synthetic customer and salesperson.
INSERT  INTO [raw_ccdata].[UsedBikes] (
    [UsedBikeID],
    [TradeInDate],
    [CustomerCode],
    [Description],
    [ModelNo],
    [Make],
    [RetailPrice],
    [CostPrice],
    [SellPrice],
    [SiteNo],
    [Salesperson_1ID],
    [Status]
)
VALUES                               (920001, '2026-01-14T00:00:00', 'TEST-CUST-1', 'Synthetic used bike', 'TEST-PROD-1', 'Test Brand', 120.00, 60.00, 100.00, 1, 900001, 'Available');

-- Verify each sales-domain raw table contains exactly one fixture record before commit.
IF (SELECT COUNT(*)
    FROM   [raw_ccdata].[Events]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[InvoiceHeader]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[InvoiceDetails]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[Quotations]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[QuotationDetails]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[SaleOrderHeader]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[SaleOrderDetails]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[SundryHeader]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[SundryDetails]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[UsedBikes]) <> 1
    BEGIN
        THROW 52162, 'Sales seed failed: fixture row counts do not match the one-row contract.', 1;
    END

COMMIT TRANSACTION;

PRINT 'Synthetic sales fixture seeded successfully.';