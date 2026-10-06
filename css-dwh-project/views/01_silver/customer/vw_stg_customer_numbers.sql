CREATE
-- OR ALTER
VIEW [stg].[customer_numbers] AS
SELECT --test
    ph.[PhoneNo] AS phone_number,
    ph.[PhoneNoType] AS phone_type,
    ph.[CustomerCode] AS customer_code
FROM
    [raw_ccdata].[CustomerPhoneNo] AS ph;
