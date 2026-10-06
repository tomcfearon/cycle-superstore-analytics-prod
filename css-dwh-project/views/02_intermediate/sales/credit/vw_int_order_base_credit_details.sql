CREATE
-- OR ALTER
VIEW [int].[order_credit_details] AS
SELECT
    d.invoice_no AS credit_number,
    d.price,
    d.qty AS quantity,
    d.vat_value AS vat_amount,
    d.[description],
    d.group_seq_no AS line_sequence_number,
    d.stock_price AS unit_price_before_discount,
    d.discount_approved_by AS discount_approver_id,
    isnull(d.stock_code, 'MISC') AS product_id,
    (d.cost * d.qty) AS cost,
    d.tax_code -- needed downstream in int_service_credits for price_before_discount VAT gross-up
FROM
    [stg].[invoice_details] AS d
WHERE
    d.trans_type = 2; -- Match the ERP salesperson credit branch, which only reads invoice-credit detail rows from trans_type 2.
