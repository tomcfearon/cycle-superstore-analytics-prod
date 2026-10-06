-- Customer dimension records require a business customer code.
IF EXISTS (SELECT 1
           FROM   [marts].[dim_customer]
           WHERE  [customer_code] IS NULL)
    BEGIN
        THROW 52000, 'Assertion failed: dim_customer.customer_code contains NULL values', 1;
    END