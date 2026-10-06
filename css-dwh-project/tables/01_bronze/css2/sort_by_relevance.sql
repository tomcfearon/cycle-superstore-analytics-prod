CREATE TABLE [raw_css2].[SortByRelevance] (
    [ItemGroupID]                  INT      NULL,
    [RelevancePoints]              INT      NULL,
    [SalesPoints]                  INT      NULL,
    [ChildStockCompletenessPoints] INT      NULL,
    [InStockAmountPoints]          INT      NULL,
    [NewnessPoints]                INT      NULL,
    [OnSalePoints]                 INT      NULL,
    [TotalSales]                   BIGINT   NULL,
    [InStoreQty]                   BIGINT   NULL,
    [SupplierQty]                  BIGINT   NULL,
    [IsOnSale]                     INT      NULL,
    [ChildCount]                   INT      NULL,
    [ChildInStockCount]            INT      NULL,
    [GroupCreatedOn]               DATE     NULL,
    [LastRefreshedOn]              DATETIME NULL
) ON [PRIMARY];