CREATE TABLE [raw_ccdata].[Products] (
    [ModelNo]               VARCHAR (50)    NULL,
    [Make]                  VARCHAR (50)    NULL,
    [StockDesc]             VARCHAR (255)   NULL,
    [Colour]                VARCHAR (50)    NULL,
    [RetailPrice]           DECIMAL (19, 2) NULL,
    [CostPrice]             DECIMAL (19, 2) NULL,
    [TradePrice]            DECIMAL (19, 2) NULL,
    [SupplierCode]          VARCHAR (50)    NULL,
    [GroupId]               VARCHAR (50)    NULL,
    [GroupId2]              VARCHAR (50)    NULL,
    [MinStockLevel]         INT             NULL,
    [ItemType]              TINYINT         NULL,
    [PartNo]                VARCHAR (50)    NULL,
    [TaxCode]               TINYINT         NULL,
    [AnalysisDept]          VARCHAR (15)    NULL,
    [AllowDiscount]         BIT             NULL,
    [SellingPrice1]         DECIMAL (19, 2) NULL,
    [SellingPrice2]         DECIMAL (19, 2) NULL,
    [SellingPrice3]         DECIMAL (19, 2) NULL,
    [SellingPrice4]         DECIMAL (19, 2) NULL,
    [SellingPrice5]         DECIMAL (19, 2) NULL,
    [SellingPrice6]         DECIMAL (19, 2) NULL,
    [SellingPrice7]         DECIMAL (19, 2) NULL,
    [SiteNo]                TINYINT         NULL,
    [AveCostPrice]          DECIMAL (19, 2) NULL,
    [TicketSKU]             VARCHAR (20)    NULL,
    [Web]                   VARCHAR (5)     NULL,
    [Status]                VARCHAR (10)    NULL,
    [Size]                  VARCHAR (10)    NULL,
    [Gender]                NVARCHAR (15)   NULL,
    [ModelYear]             VARCHAR (10)    NULL,
    [SalePrice]             DECIMAL (19, 2) NULL,
    [SaleStartDate]         DATETIME        NULL,
    [SaleEndDate]           DATETIME        NULL,
    [TradeSalePrice]        DECIMAL (19, 2) NULL,
    [TradeSaleStartDate]    DATETIME        NULL,
    [TradeSaleEndDate]      DATETIME        NULL,
    [CommodityCode]         VARCHAR (50)    NULL,
    [CountryOfOrigin]       VARCHAR (20)    NULL,
    [Weight]                DECIMAL (19, 2) NULL,
    -- Keep incremental raw landing schema aligned with current ERP source columns.
    [LastPriceChangeDate]   DATETIME        NULL,
    [row_modified_datetime] DATETIME        NULL
) ON [PRIMARY];


GO
-- Product master join key
CREATE NONCLUSTERED INDEX [ix_products_modelno]
    ON [raw_ccdata].[Products]([ModelNo]);