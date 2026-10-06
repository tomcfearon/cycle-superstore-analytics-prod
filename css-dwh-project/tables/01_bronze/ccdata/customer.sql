CREATE TABLE [raw_ccdata].[Customer] (
    [CustomerCode]          VARCHAR (12)    NULL,
    [LastName]              VARCHAR (50)    NULL,
    [Address1]              VARCHAR (255)   NULL,
    [Address2]              VARCHAR (255)   NULL,
    [Town]                  VARCHAR (50)    NULL,
    [County]                VARCHAR (50)    NULL,
    [PostCode]              VARCHAR (12)    NULL,
    [CustomerType]          VARCHAR (20)    NULL,
    [PriceBand]             TINYINT         NULL,
    [Notes]                 VARCHAR (4000)  NULL,
    [MailShotFlag]          BIT             NULL,
    [OnStop]                BIT             NULL,
    [Reason]                VARCHAR (255)   NULL,
    [AccountOpenedDate]     DATETIME        NULL,
    [AccountBalance]        DECIMAL (19, 2) NULL,
    [CreditBalance]         DECIMAL (19, 2) NULL,
    [TurnOverToDate]        DECIMAL (19, 2) NULL,
    [EMailAddress]          VARCHAR (100)   NULL,
    [InvCustCode]           VARCHAR (12)    NULL,
    [NextActionText]        VARCHAR (255)   NULL,
    [CompanyName]           VARCHAR (100)   NULL,
    [FirstName]             VARCHAR (50)    NULL,
    [Country]               VARCHAR (50)    NULL,
    [OrigSalesperson]       VARCHAR (50)    NULL,
    [SiteNo]                TINYINT         NULL,
    [Sex]                   TINYINT         NULL,
    [VATRegNo]              VARCHAR (20)    NULL,
    [EmpRefNo]              VARCHAR (50)    NULL,
    [CreditTerms]           INT             NULL,
    [CreditLimit]           DECIMAL (19, 2) NULL,
    [TypeOfRiding]          VARCHAR (50)    NULL,
    [TaxLevel]              INT             NULL,
    [Refer]                 VARCHAR (50)    NULL,
    [SMSCommunication]      BIT             NULL,
    [LastInStoreDate]       DATETIME        NULL,
    [LastModifiedDate]      DATETIME        NULL,
    [Archived]              BIT             NULL,
    [Comments]              VARCHAR (2000)  NULL,
    [LocationID]            VARCHAR (50)    NULL,
    [row_modified_datetime] DATETIME        NULL
) ON [PRIMARY];


GO
-- Join key across nearly every customer-facing view; not UNIQUE since uniqueness hasn't been verified
CREATE NONCLUSTERED INDEX [ix_customer_customercode]
    ON [raw_ccdata].[Customer]([CustomerCode]);