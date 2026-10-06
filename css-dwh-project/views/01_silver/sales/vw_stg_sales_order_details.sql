CREATE
-- OR ALTER
VIEW [stg].[sales_order_details] AS
SELECT
    sod.TransType AS trans_type,
    sod.InvoiceNo AS order_number,
    ISNULL(sod.StockCode, 'MISC') AS product_id,
    sod.StockCode AS stock_code,
    sod.Price AS price,
    sod.Qty AS quantity,
    sod.VATValue AS vat_amount,
    sod.Cost AS unit_cost,
    (sod.Cost * sod.Qty) AS cost,
    sod.[Description] AS [description],
    sod.Reason AS reason,
    sod.GroupSeqNo AS line_sequence_number,
    sod.QtyTaken AS quantity_taken,
    sod.AnalysisDept AS analysis_dept,
    sod.OrigPrice AS orig_price,
    sod.OrigVATValue AS orig_vat_value,
    sod.TaxCode AS tax_code,
    sod.ModelNo AS model_no,
    sod.StatusItemType AS status_item_type,
    sod.StockPrice AS unit_price_before_discount,
    sod.SiteNo AS site_no,
    sod.StockLocation AS stock_location,
    NULLIF(sod.RequestID, 0) AS request_id,
    sod.RequestID AS request_id_raw,
    CASE
        WHEN sod.BikePulled IS NULL THEN 0
        WHEN sod.BikePulled = 2 THEN 1
        ELSE sod.BikePulled
    END AS is_pulled,
    sod.BikePulled AS bike_pulled,
    sod.DiscountApprovedBy AS discount_approver_id,
    sod.MultiBuyDiscount AS multi_buy_discount,
    sod.BrakeSetup AS brake_setup
FROM
    raw_ccdata.SaleOrderDetails AS sod
WHERE
    sod.InvoiceNo IS NOT NULL;
