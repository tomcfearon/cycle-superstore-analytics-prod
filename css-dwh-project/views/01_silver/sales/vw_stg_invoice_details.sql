CREATE
-- OR ALTER
VIEW [stg].[invoice_details] AS
SELECT
    d.TransType AS trans_type,
    d.InvoiceNo AS invoice_no,
    d.StockCode AS stock_code,
    d.Price AS price,
    d.Qty AS qty,
    d.VATValue AS vat_value,
    d.ReturnToStock AS return_to_stock,
    d.Cost AS cost,
    d.[Description] AS [description],
    d.Reason AS reason,
    d.GroupSeqNo AS group_seq_no,
    d.QtyTaken AS qty_taken,
    d.AnalysisDept AS analysis_dept,
    d.OrigPrice AS orig_price,
    d.OrigVATValue AS orig_vat_value,
    d.Credited AS credited,
    d.CreditNo AS credit_no,
    d.TaxCode AS tax_code,
    d.StockPrice AS stock_price,
    d.SiteNo AS site_no,
    d.StockLocation AS stock_location,
    d.DiscountApprovedBy AS discount_approved_by,
    d.MultiBuyDiscount AS multi_buy_discount,
    d.BrakeSetup AS brake_setup
FROM
    raw_ccdata.InvoiceDetails AS d;
