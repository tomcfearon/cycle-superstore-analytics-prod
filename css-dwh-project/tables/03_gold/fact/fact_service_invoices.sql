CREATE TABLE [marts].[fct_service_invoices] (
    [transaction_key]        VARCHAR (20)    NULL,
    [order_number]           VARCHAR (12)    NULL, -- FK to parent service order
    [customer_code]          VARCHAR (12)    NULL,
    -- Keys
    [salesperson_key]        INT             NOT NULL,
    [engineer_key]           INT             NOT NULL,
    [supervisor_key]         INT             NULL,
    [approver_key]           INT             NULL,
    [product_key]            VARCHAR (52)    NOT NULL,
    [web_order_id]           INT             NULL,
    -- Dates
    [order_date]             DATE            NULL,
    [invoice_date]           DATE            NULL,
    [repair_date]            DATE            NULL,
    [repair_time]            INT             NULL,
    [completion_date]        DATE            NULL,
    [collection_date]        DATE            NULL,
    [last_modified_datetime] DATETIME        NULL,
    [row_modified_datetime]  DATETIME        NULL,
    -- Status
    [invoice_status]         VARCHAR (20)    NULL,
    [is_urgent]              BIT             NULL,
    [is_faulty]              BIT             NULL,
    [is_credited]            BIT             NULL,
    -- Metrics
    [estimate_given]         VARCHAR (100)   NULL,
    [total_labour_cost]      DECIMAL (19, 2) NULL,
    [payment_to_date]        DECIMAL (19, 2) NULL,
    [credit_note_number]     VARCHAR (12)    NULL,
    [credit_number]          VARCHAR (12)    NULL,
    [quantity]               INT             NOT NULL,
    -- Financials
    [price]                  DECIMAL (38, 6) NULL,
    [vat_amount]             DECIMAL (38, 6) NULL,
    [price_before_discount]  DECIMAL (30, 2) NOT NULL,
    [cost]                   DECIMAL (18, 2) NULL,
    -- Meta
    [description]            VARCHAR (255)   NULL,
    [line_sequence_number]   INT             NOT NULL,
    is_company_stock         BIT             NULL,
    is_wheel                 BIT             NULL,
    is_fork                  BIT             NULL,
    is_pedal                 BIT             NULL,
    service_type_key         INT             NULL, -- FK to dim_service_type; resolved from service_category at mart load
    bike_brand               VARCHAR (50)    NULL,
    misc_title               VARCHAR (255)   NULL,
    [order_channel]          VARCHAR (50)    NULL,
    [service_bike_id]        VARCHAR (50)    NULL
) ON [PRIMARY];


GO
CREATE CLUSTERED COLUMNSTORE INDEX [cci_fct_service_invoices]
    ON [marts].[fct_service_invoices] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
    ON [PRIMARY];


GO
-- Enforces the line grain and gives the loader MERGE a seek target instead of a full scan
CREATE UNIQUE NONCLUSTERED INDEX [uq_fct_service_invoices_transaction_line]
    ON [marts].[fct_service_invoices]([transaction_key], [line_sequence_number]);