CREATE TABLE [marts].[fct_order_invoices] (
    [transaction_key]           VARCHAR (20)    NULL,
    [invoice_date]              DATE            NULL,
    [customer_code]             VARCHAR (12)    NULL,
    [employee_key]              INT             NOT NULL,
    [creditor_key]              INT             NULL,
    [product_key]               VARCHAR (52)    NOT NULL,
    [quantity]                  INT             NULL,
    [price]                     DECIMAL (19, 2) NULL,
    [vat_amount]                DECIMAL (19, 2) NULL,
    [cost]                      NUMERIC (34, 6) NULL,
    [price_before_discount]     DECIMAL (30, 2) NULL,
    [approver_key]              INT             NULL,
    [order_date]                DATE            NULL,
    [order_time]                TIME (0)        NULL,
    [invoice_connection_number] VARCHAR (50)    NULL,
    [web_order_id]              INT             NULL,
    [line_sequence_number]      INT             NULL,
    [description]               VARCHAR (255)   NULL,
    [last_modified_datetime]    DATETIME        NULL,
    [row_modified_datetime]     DATETIME        NULL,
    [is_dispatched]             TINYINT         NOT NULL,
    [is_used_bike_invoice]      BIT             NOT NULL,
    [collection_employee_key]   INT             NULL,
    [is_credited]               BIT             NOT NULL,
    [order_channel]             VARCHAR (50)    NULL
) ON [PRIMARY];


GO
CREATE CLUSTERED COLUMNSTORE INDEX [marts_fct_order_invoices__dbt_tmp_cci]
    ON [marts].[fct_order_invoices] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
    ON [PRIMARY];


GO
-- Enforces the line grain and gives the loader MERGE a seek target instead of a full scan
CREATE UNIQUE NONCLUSTERED INDEX [uq_fct_order_invoices_transaction_line]
    ON [marts].[fct_order_invoices]([transaction_key], [line_sequence_number]);