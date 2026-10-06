CREATE TABLE [marts].[fct_till_credits] (
    [transaction_key]           VARCHAR (20)    NULL,
    [credit_date]               DATE            NULL,
    [customer_code]             VARCHAR (12)    NULL,
    [employee_key]              INT             NULL,
    [creditor_key]              INT             NULL,
    [product_key]               VARCHAR (52)    NOT NULL,
    [quantity]                  INT             NOT NULL,
    [price]                     DECIMAL (19, 2) NOT NULL,
    [vat_amount]                DECIMAL (19, 2) NOT NULL,
    [cost]                      DECIMAL (30, 2) NOT NULL,
    [price_before_discount]     DECIMAL (30, 2) NULL,
    [approver_key]              INT             NULL,
    [order_date]                DATE            NULL,
    [order_time]                TIME (0)        NULL,
    [is_dispatched]             BIT             NULL,
    [invoice_connection_number] VARCHAR (50)    NULL,
    [line_sequence_number]      INT             NULL,
    [description]               VARCHAR (255)   NULL,
    [last_modified_datetime]    DATETIME        NULL,
    [order_channel]             VARCHAR (50)    NULL,
    [is_from_invoice_note]      BIT             NULL
) ON [PRIMARY];


GO
CREATE CLUSTERED COLUMNSTORE INDEX [marts_fct_till_credits__dbt_tmp_cci]
    ON [marts].[fct_till_credits] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
    ON [PRIMARY];


GO
-- Enforces the line grain and gives the loader MERGE a seek target instead of a full scan
CREATE UNIQUE NONCLUSTERED INDEX [uq_fct_till_credits_transaction_line]
    ON [marts].[fct_till_credits]([transaction_key], [line_sequence_number]);