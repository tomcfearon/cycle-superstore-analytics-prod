-- Employee dimension records require a surrogate employee key.
IF EXISTS (SELECT 1
           FROM   [marts].[dim_employee]
           WHERE  [employee_key] IS NULL)
    BEGIN
        THROW 52000, 'Assertion failed: dim_employee.employee_key contains NULL values', 1;
    END