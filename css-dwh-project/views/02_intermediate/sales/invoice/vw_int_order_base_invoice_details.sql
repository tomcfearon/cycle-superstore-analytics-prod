CREATE
-- OR ALTER
VIEW [int].[order_invoice_details] AS
SELECT
    d.invoice_no AS invoice_number,
    d.price,
    d.qty AS quantity,
    d.vat_value AS vat_amount,
    d.[description],
    d.group_seq_no AS line_sequence_number,
    d.credited AS is_credited,
    d.stock_price AS unit_price_before_discount,
    d.discount_approved_by AS discount_approver_id,
    isnull(d.stock_code, 'MISC') AS product_id,
    (d.cost * d.qty) AS cost,
    nullif(trim(d.credit_no), '') AS credit_note_number
FROM
    [stg].[invoice_details] AS d
WHERE
    d.trans_type = 1; -- Match the ERP salesperson report, which reads only trans_type 1 sales invoice detail rows.
