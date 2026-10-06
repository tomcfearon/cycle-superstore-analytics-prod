CREATE
-- OR ALTER
VIEW [stg].[sundry_details] AS
SELECT
    sd.TransType AS trans_type,
    sd.InvoiceNo AS invoice_no,
    sd.StockCode AS stock_code,
    sd.Price AS price,
    sd.Qty AS qty,
    sd.VATValue AS vat_value,
    sd.Cost AS cost,
    sd.[Description] AS [description],
    sd.GroupSeqNo AS group_seq_no,
    sd.AnalysisDept AS analysis_dept,
    sd.TaxCode AS tax_code,
    sd.StockPrice AS stock_price,
    sd.SiteNo AS site_no,
    sd.StockLocation AS stock_location,
    sd.RefundItem AS refund_item,
    sd.MultiBuyDiscount AS multi_buy_discount,
    sd.Reason AS reason
    -- row_modified_datetime removed: SundryDetails is full-reload (DROP + autoCreate each ADF run)
    -- so the column never survives the pipeline. Not consumed by any downstream view.
FROM
    raw_ccdata.SundryDetails AS sd;
