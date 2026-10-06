-- Inventory snapshot lives in its own raw schema
CREATE TABLE [raw_ccdata].[Inventory] (
    [stock_key]             NVARCHAR (MAX) NULL,
    [quantity_on_hand_t1]   INT            NULL,
    [quantity_on_hand_t2]   INT            NULL,
    [quantity_on_hand_cara] INT            NULL,
    [query_datetime]        DATETIME2 (7)  NULL,
    [query_date]            DATE           NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];