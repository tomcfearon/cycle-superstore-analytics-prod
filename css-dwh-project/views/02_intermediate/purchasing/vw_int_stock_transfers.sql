CREATE
-- OR ALTER
VIEW [int].[stock_transfers] AS
SELECT -- Header
    h.order_no,
    h.order_date,
    h.due_in_date,
    h.goods_in_date,
    h.salesperson,
    h.goods_in_salesperson,
    h.order_ref,
    h.delivery_note_no,
    h.notes,
    h.additional_cost,
    h.order_ref_total,
    h.conversion_rate_gbp,
    h.settlement_discount,
    -- Line
    d.line_no,
    d.item_type,
    d.stock_code,
    d.brand,
    d.description,
    d.stock_location,
    d.qty,
    d.qty_received,
    d.cost,
    d.retail_price,
    d.trade_price,
    d.special_price,
    d.booked_date,
    d.item_category
FROM [stg].[purchase_order_header] AS h
INNER JOIN [stg].[purchase_order_details] AS d ON h.order_no = d.order_no
WHERE h.trans_type = 2;