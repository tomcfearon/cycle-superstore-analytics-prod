SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse fixture writes outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52110, 'Customer seed refused: the current database is not css-dwh-test.', 1;
    END

-- Require the customer-domain raw tables to be empty before seeding deterministic fixtures.
IF EXISTS (SELECT 1
           FROM   [raw_ccdata].[Customer])
   OR EXISTS (SELECT 1
              FROM   [raw_ccdata].[CustomerPhoneNo])
   OR EXISTS (SELECT 1
              FROM   [raw_css2].[customers])
   OR EXISTS (SELECT 1
              FROM   [raw_365].[365_mail])
    BEGIN
        THROW 52111, 'Customer seed refused: fixture tables are not empty. Run reset_test_database.sql first.', 1;
    END

BEGIN TRANSACTION;

-- Seed the ERP customer before records that reference its customer code.
INSERT  INTO [raw_ccdata].[Customer] (
    [CustomerCode],
    [LastName],
    [CustomerType],
    [PriceBand],
    [OnStop],
    [AccountOpenedDate],
    [CreditBalance],
    [EMailAddress],
    [CompanyName],
    [FirstName],
    [Sex],
    [CreditTerms],
    [CreditLimit],
    [LastInStoreDate],
    [Archived],
    [row_modified_datetime]
)
VALUES                              ('TEST-CUST-1', 'Customer', 'Retail', 1, 0, '2026-01-01T00:00:00', 0.00, 'warehouse.test@example.invalid', 'Cycle Superstore Test', 'Integration', 0, 30, 1000.00, '2026-01-15T00:00:00', 0, '2026-01-15T12:00:00');

-- Link the customer's deterministic contact number to the ERP customer record.
INSERT  INTO [raw_ccdata].[CustomerPhoneNo] (
    [PhoneNo],
    [PhoneNoType],
    [CustomerCode]
)
VALUES                                     ('02000000001', 'Mobile', 'TEST-CUST-1');

-- Seed the matching web-customer source record used by customer consolidation.
INSERT  INTO [raw_css2].[customers] (
    [idcustomer],
    [name],
    [lastName],
    [customerCompany],
    [phone],
    [email],
    [pcCust_DateCreated],
    [customerType],
    [SiteNo],
    [GuestAccount]
)
VALUES                             (900001, N'Integration', N'Customer', N'Cycle Superstore Test', N'02000000001', N'warehouse.test@example.invalid', '2026-01-01T00:00:00', 1, 1, 0);

-- Seed a customer-addressed email that can join to the conformed customer by email address.
INSERT  INTO [raw_365].[365_mail] (
    [receivedDateTime],
    [subject],
    [bodyPreview],
    [name],
    [address],
    [ingested_time],
    [source_mailbox_upn],
    [conversation_id],
    [webLink],
    [body_content_type],
    [body_content],
    [body_text]
)
VALUES                           (N'2026-01-15T12:00:00Z', N'Integration test customer email', N'Synthetic customer fixture email.', N'Integration Customer', N'warehouse.test@example.invalid', '2026-01-15T12:00:00', N'test-mailbox@example.invalid', N'TEST-CONVERSATION-1', N'https://example.invalid/messages/TEST-CONVERSATION-1', N'text', N'Test customer email', N'Synthetic customer fixture email.');

-- Verify each customer-domain raw table contains exactly one fixture record before commit.
IF (SELECT COUNT(*)
    FROM   [raw_ccdata].[Customer]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_ccdata].[CustomerPhoneNo]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_css2].[customers]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_365].[365_mail]) <> 1
    BEGIN
        THROW 52112, 'Customer seed failed: fixture row counts do not match the one-row contract.', 1;
    END

COMMIT TRANSACTION;

PRINT 'Synthetic customer fixture seeded successfully.';