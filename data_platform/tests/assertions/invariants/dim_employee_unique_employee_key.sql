-- Employee dimension records must have one row for each populated employee key.
IF EXISTS (SELECT   [employee_key]
           FROM     [marts].[dim_employee]
           WHERE    [employee_key] IS NOT NULL
           GROUP BY [employee_key]
           HAVING   COUNT(*) > 1)
    BEGIN
        THROW 52001, 'Assertion failed: dim_employee.employee_key has duplicate values', 1;
    END