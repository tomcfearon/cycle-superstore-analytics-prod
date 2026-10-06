CREATE
-- OR ALTER
VIEW [int].[pos_credit_notes_details] AS
SELECT
    sd.invoice_no AS credit_number,
    sd.price,
    sd.qty AS quantity,
    sd.vat_value AS vat_amount,
    sd.[description],
    sd.group_seq_no AS line_sequence_number,
    sd.stock_price AS unit_price_before_discount,
    sd.refund_item AS is_credited,
    isnull(sd.stock_code, 'MISC') AS product_id,
    (sd.cost * sd.qty) AS cost
FROM
    [stg].[sundry_details] AS sd
WHERE
    sd.trans_type = 4
    AND sd.stock_code IS NOT NULL -- Mirror the ERP sundry return branch, which excludes non-stock sundry rows from salesperson revenue.
    AND sd.invoice_no IS NOT NULL
    AND trim(sd.invoice_no) <> '';
