-- Customer dimension records must have one row for each populated customer code.
IF EXISTS (SELECT   [customer_code]
           FROM     [marts].[dim_customer]
           WHERE    [customer_code] IS NOT NULL
           GROUP BY [customer_code]
           HAVING   COUNT(*) > 1)
    BEGIN
        THROW 52001, 'Assertion failed: dim_customer.customer_code has duplicate values', 1;
    END