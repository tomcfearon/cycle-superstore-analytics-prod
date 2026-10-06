CREATE TABLE [raw_ccdata].[CustomerPhoneNo] (
    [PhoneNo]      VARCHAR (100) NULL,
    [PhoneNoType]  VARCHAR (10)  NULL,
    [CustomerCode] VARCHAR (12)  NULL
) ON [PRIMARY];


GO
-- Confirmed join in vw_int_customers.sql
CREATE NONCLUSTERED INDEX [ix_customer_phone_no_customercode]
    ON [raw_ccdata].[CustomerPhoneNo]([CustomerCode]);