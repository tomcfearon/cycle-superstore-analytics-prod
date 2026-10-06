CREATE TABLE [marts].[fct_xero_bank_transaction_credits] (
    [bank_transaction_id] NVARCHAR (100)  NOT NULL,
    [transaction_date]    DATE            NULL,
    [contact_name]        NVARCHAR (255)  NULL,
    [contact_type]        VARCHAR (20)    NULL,
    [account_code]        VARCHAR (50)    NULL,
    [amount]              DECIMAL (18, 2) NULL,
    [tax_amount]          DECIMAL (18, 2) NULL,
    [description]         NVARCHAR (MAX)  NULL,
    [currency_code]       VARCHAR (10)    NULL,
    [updated_date_utc]    DATETIME2 (3)   NULL
) ON [PRIMARY];


GO
CREATE CLUSTERED INDEX [marts_fct_xero_bank_transaction_credits_ci]
    ON [marts].[fct_xero_bank_transaction_credits]([transaction_date], [bank_transaction_id]);