GO
CREATE
-- OR ALTER
VIEW [stg].[purchase_order_header] AS
SELECT p.OrderNo AS order_no,
    p.Salesperson AS salesperson,
    p.SupplierCode AS supplier_code,
    p.OrderDate AS order_date,
    p.DueIn AS due_in_date,
    p.OrderRef AS order_ref,
    NULLIF(p.Notes, '') AS notes,
    p.SiteNo AS site_no,
    --useless
    p.AdditionalCost AS additional_cost,
    p.OrderRefTotal AS order_ref_total,
    p.ConversionRateGBP AS conversion_rate_gbp,
    p.DeliveryNoteNo AS delivery_note_no,
    p.TransType AS trans_type,
    -- 1 input 2 transfer
    p.GoodsInDate AS goods_in_date,
    p.GoodsInSalesPerson AS goods_in_salesperson,
    p.SettlementDiscount AS settlement_discount
FROM [raw_ccdata].[PurchaseOrderHeader] AS p;
