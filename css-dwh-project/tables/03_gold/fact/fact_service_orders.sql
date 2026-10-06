CREATE TABLE [marts].[fct_service_orders] (
    [transaction_key]        VARCHAR (20)    NULL,
    [order_date]             DATE            NULL,
    [repair_date]            DATE            NULL,
    [collection_date]        DATE            NULL,
    [customer_code]          VARCHAR (12)    NULL,
    -- Keys
    [salesperson_key]        INT             NOT NULL,
    [engineer_key]           INT             NULL,
    [supervisor_key]         INT             NULL,
    [approver_key]           INT             NULL,
    [product_key]            VARCHAR (52)    NOT NULL,
    [web_order_id]           INT             NULL,
    -- IDs
    [service_bike_id]        VARCHAR (50)    NULL,
    -- Added this to match your new View
    -- Status
    [order_status]           VARCHAR (50)    NULL,
    [is_urgent]              BIT             NULL,
    [is_faulty]              BIT             NULL,
    -- Metrics
    [total_labour_cost]      DECIMAL (19, 2) NULL,
    [repair_time]            INT             NULL,
    [estimate_given]         VARCHAR (100)   NULL,
    [quantity]               INT             NULL,
    -- Financials
    [price]                  DECIMAL (38, 6) NULL,
    [vat_amount]             DECIMAL (38, 6) NULL,
    [price_before_discount]  DECIMAL (30, 2) NOT NULL,
    [cost]                   DECIMAL (18, 2) NULL,
    -- Meta
    [description]            VARCHAR (255)   NULL,
    [line_sequence_number]   INT             NOT NULL,
    [last_modified_datetime] DATETIME        NULL,
    [row_modified_datetime]  DATETIME        NULL,
    is_company_stock         BIT             NULL,
    is_wheel                 BIT             NULL,
    is_fork                  BIT             NULL,
    is_pedal                 BIT             NULL,
    service_type_key         INT             NULL, -- FK to dim_service_type; resolved from service_category at mart load
    bike_brand               VARCHAR (50)    NULL,
    misc_title               VARCHAR (255)   NULL,
    [order_channel]          VARCHAR (50)    NULL
) ON [PRIMARY];


GO
CREATE CLUSTERED COLUMNSTORE INDEX [cci_fct_service_orders]
    ON [marts].[fct_service_orders] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
    ON [PRIMARY];


GO
-- Enforces the line grain and gives the loader MERGE a seek target instead of a full scan
CREATE UNIQUE NONCLUSTERED INDEX [uq_fct_service_orders_transaction_line]
    ON [marts].[fct_service_orders]([transaction_key], [line_sequence_number]);