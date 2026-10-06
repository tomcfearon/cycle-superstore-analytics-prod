-- The order-invoice fixture must resolve its seeded dimensions and transaction key.
IF (SELECT COUNT(*)
    FROM   [marts].[dim_customer]
    WHERE  [customer_code] = 'TEST-CUST-1') <> 1
    THROW 52120, 'Assertion failed: expected one TEST-CUST-1 customer dimension row.', 1;

IF (SELECT COUNT(*)
    FROM   [marts].[dim_employee]
    WHERE  [employee_key] = 900001) <> 1
    THROW 52121, 'Assertion failed: expected one employee dimension row for key 900001.', 1;

IF (SELECT COUNT(*)
    FROM   [marts].[dim_product]
    WHERE  [product_key] = 'MISC-3') <> 1
    THROW 52122, 'Assertion failed: expected one MISC-3 product dimension row.', 1;

IF (SELECT COUNT(*)
    FROM   [marts].[dim_transaction]
    WHERE  [transaction_key] = 'ORD-INV-TST-INV-1') <> 1
    THROW 52123, 'Assertion failed: expected one ORD-INV-TST-INV-1 transaction dimension row.', 1;

-- A single raw invoice detail must produce exactly one order-invoice fact row.
IF (SELECT COUNT(*)
    FROM   [marts].[fct_order_invoices]
    WHERE  [transaction_key] = 'ORD-INV-TST-INV-1') <> 1
    THROW 52124, 'Assertion failed: synthetic order invoice produced duplicate or missing fact rows.', 1;

-- Verify the order-invoice transformation, including financial fields and channel classification.
IF (SELECT COUNT(*)
    FROM   [marts].[fct_order_invoices]
    WHERE  [transaction_key] = 'ORD-INV-TST-INV-1'
           AND [customer_code] = 'TEST-CUST-1'
           AND [employee_key] = 900001
           AND [product_key] = 'MISC-3'
           AND [quantity] = 2
           AND [price] = 120.00
           AND [vat_amount] = 20.00
           AND [cost] = 60.00
           AND [price_before_discount] = 120.00
           AND [invoice_date] = '2026-01-15'
           AND [order_date] = '2026-01-14'
           AND [order_channel] = 'In-Store'
           AND [is_dispatched] = 1
           AND [is_credited] = 0) <> 1
    THROW 52125, 'Assertion failed: synthetic order invoice fact values do not match the fixture contract.', 1;

PRINT 'PASS: synthetic order-invoice fixture assertions.';