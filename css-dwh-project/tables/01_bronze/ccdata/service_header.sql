CREATE TABLE [raw_ccdata].[Repairs] (
    [FaultNo]                 VARCHAR (12)    NULL,
    [Faultdate]               DATETIME        NULL,
    [RepairDate]              DATETIME        NULL,
    [DateCompleted]           DATETIME        NULL,
    [CustomerCode]            VARCHAR (12)    NULL,
    [InvoiceNo]               VARCHAR (12)    NULL,
    [InvoiceDate]             DATETIME        NULL,
    [InvCustCode]             VARCHAR (12)    NULL,
    [Salesperson]             VARCHAR (50)    NULL,
    [Engineer]                VARCHAR (50)    NULL,
    [Source]                  VARCHAR (20)    NULL,
    [CurrentStatus]           VARCHAR (30)    NULL,
    [Collected]               BIT             NULL,
    [CollectDate]             DATETIME        NULL,
    [CollectTime]             VARCHAR (20)    NULL,
    [StockCode]               VARCHAR (50)    NULL,
    [Comments]                VARCHAR (4000)  NULL,
    [RepairType]              VARCHAR (25)    NULL,
    [WorkDone]                VARCHAR (4000)  NULL,
    [FaultDescription]        VARCHAR (4000)  NULL,
    [TotalCost]               DECIMAL (19, 2) NULL,
    [TotalLabour]             DECIMAL (19, 2) NULL,
    [TotalParts]              DECIMAL (19, 2) NULL,
    [VATCharge]               DECIMAL (19, 2) NULL,
    [TotalCharge]             DECIMAL (19, 2) NULL,
    [VatRate]                 DECIMAL (4, 2)  NULL,
    [PaymentToDate]           DECIMAL (19, 2) NULL,
    [DiscountToDate]          DECIMAL (19, 2) NULL,
    [WriteOffToDate]          DECIMAL (19, 2) NULL,
    [RefundValue]             DECIMAL (19, 2) NULL,
    [RefundNo]                VARCHAR (12)    NULL,
    [JobType]                 VARCHAR (30)    NULL,
    [AnalysisDept]            VARCHAR (15)    NULL,
    [ReturnDateSent]          DATETIME        NULL,
    [ReturnSupplierCode]      VARCHAR (50)    NULL,
    [ReturnType]              VARCHAR (30)    NULL,
    [ReturnReason]            VARCHAR (4000)  NULL,
    [ReturnDateBack]          DATETIME        NULL,
    [SiteNo]                  TINYINT         NULL,
    [ServiceRef]              VARCHAR (255)   NULL,
    [InStoreMemo]             VARCHAR (8000)  NULL,
    [TimeSpent]               INT             NULL,
    [CustEstimate]            VARCHAR (100)   NULL,
    [TransType]               TINYINT         NULL,
    [RefundPayment]           DECIMAL (19, 2) NULL,
    [FirstService]            BIT             NULL,
    [UnderWarranty]           BIT             NULL,
    [Urgent]                  BIT             NULL,
    [ReturnNo]                VARCHAR (50)    NULL,
    [ReturnItemCost]          DECIMAL (19, 2) NULL,
    [ReturnItemQty]           INT             NULL,
    [ReturnItemCN]            VARCHAR (50)    NULL,
    [ItemDocumenNo]           VARCHAR (50)    NULL,
    [ItemReturnedToStock]     BIT             NULL,
    [ReturnSupplierCN]        VARCHAR (50)    NULL,
    [BoxNo]                   INT             NULL,
    [ReturnItemStockLocation] VARCHAR (50)    NULL,
    [ManagerCheckUserID]      INT             NULL,
    [ReturnSupplierCNAmount]  DECIMAL (19, 2) NULL,
    [LastModifiedDate]        DATETIME        NULL,
    [WebWarrantyFormID]       INT             NULL,
    [WebServiceBookedID]      INT             NULL,
    [ReturnItemGroupSeqNo]    SMALLINT        NULL,
    [WarrantyRequested]       INT             NULL,
    [row_modified_datetime]   DATETIME        NULL
) ON [PRIMARY];


GO
-- InvoiceNo is the anti-join key in vw_int_order_credits (the query that ran 8+ minutes); FaultNo joins RepairsDetails
CREATE NONCLUSTERED INDEX [ix_repairs_invoiceno]
    ON [raw_ccdata].[Repairs]([InvoiceNo])
    INCLUDE([FaultNo], [CustomerCode], [Salesperson]);


GO
CREATE NONCLUSTERED INDEX [ix_repairs_faultno]
    ON [raw_ccdata].[Repairs]([FaultNo]);