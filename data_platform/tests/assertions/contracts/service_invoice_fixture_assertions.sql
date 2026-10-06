-- The service fixture must resolve its customer, employee, product fallback, and transaction dimensions.
IF (SELECT COUNT(*)
    FROM   [marts].[dim_customer]
    WHERE  [customer_code] = 'TEST-CUST-1') <> 1
    THROW 52130, 'Assertion failed: expected one TEST-CUST-1 customer dimension row for the service fixture.', 1;

IF (SELECT COUNT(*)
    FROM   [marts].[dim_employee]
    WHERE  [employee_key] = 900001) <> 1
    THROW 52131, 'Assertion failed: expected one employee dimension row for key 900001 in the service fixture.', 1;

IF (SELECT COUNT(*)
    FROM   [marts].[dim_product]
    WHERE  [product_key] = 'MISC-3') <> 1
    THROW 52132, 'Assertion failed: expected one MISC-3 product dimension row for the service fixture.', 1;

IF (SELECT COUNT(*)
    FROM   [marts].[dim_transaction]
    WHERE  [transaction_key] = 'SVC-INV-TST-SRV-INV') <> 1
    THROW 52133, 'Assertion failed: expected one SVC-INV-TST-SRV-INV transaction dimension row.', 1;

-- A single raw repair detail must produce exactly one service-invoice fact row.
IF (SELECT COUNT(*)
    FROM   [marts].[fct_service_invoices]
    WHERE  [transaction_key] = 'SVC-INV-TST-SRV-INV') <> 1
    THROW 52134, 'Assertion failed: synthetic service invoice produced duplicate or missing fact rows.', 1;

-- Verify the service transformation, including its employee lookup, financial calculations, and channel classification.
IF (SELECT COUNT(*)
    FROM   [marts].[fct_service_invoices]
    WHERE  [transaction_key] = 'SVC-INV-TST-SRV-INV'
           AND [order_number] = 'TST-SRV-1'
           AND [customer_code] = 'TEST-CUST-1'
           AND [salesperson_key] = 900001
           AND [engineer_key] = 900001
           AND [product_key] = 'TEST-STOCK-1-0'
           AND [quantity] = 1
           AND [price] = 30.00
           AND [vat_amount] = 0.00
           AND [price_before_discount] = 30.00
           AND [cost] = 20.00
           AND [invoice_date] = '2026-01-15'
           AND [repair_date] = '2026-01-14'
           AND [completion_date] = '2026-01-15'
           AND [invoice_status] = 'Completed'
           AND [is_faulty] = 1
           AND [is_credited] = 0
           AND [line_sequence_number] = 1
           AND [order_channel] = 'In-Store') <> 1
    THROW 52135, 'Assertion failed: synthetic service invoice fact values do not match the fixture contract.', 1;

PRINT 'PASS: synthetic service-invoice fixture assertions.';