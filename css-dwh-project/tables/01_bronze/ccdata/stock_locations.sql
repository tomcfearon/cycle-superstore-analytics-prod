CREATE TABLE [raw_ccdata].[StockCountedLocations] (
    [StockCode]     VARCHAR (50) NULL,
    [StockLocation] VARCHAR (50) NULL,
    [QtyOnHand]     INT          NULL,
    [QtyOnOrder]    INT          NULL,
    [QtyReserved]   INT          NULL,
    [MinStockLevel] INT          NULL,
    [DateSold]      DATETIME     NULL,
    [MaxStockLevel] INT          NULL,
    [QtyFaulty]     INT          NULL,
    [DateCounted]   DATETIME     NULL,
    [BinNo]         VARCHAR (50) NULL
) ON [PRIMARY];


GO
-- Product key join column
CREATE NONCLUSTERED INDEX [ix_stock_counted_locations_stockcode]
    ON [raw_ccdata].[StockCountedLocations]([StockCode]);