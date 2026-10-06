CREATE VIEW -- OR ALTER
[int].[base_repair_details]
AS
SELECT rd.fault_no AS order_number,
       rd.group_seq_no AS line_sequence_number,
       -- Item Details
       rd.[description],
       ISNULL(rd.stock_code, 'MISC') AS product_id,
       ISNULL(rd.quantity, 0) AS quantity,
       -- Pricing
       rd.stock_price AS unit_price_before_discount,
       CAST (ISNULL(rd.sell_price * rd.quantity, 0) AS DECIMAL (18, 2)) AS price_ex_vat,
       CAST (ISNULL(rd.cost_price * rd.quantity, 0) AS DECIMAL (18, 2)) AS raw_cost,
       -- Price before discount inc. VAT (unit price × quantity × gross-up; mirrors order invoice price_before_discount)
       CAST (ISNULL(rd.stock_price, 0) * ISNULL(rd.quantity, 0) * (1 + CASE WHEN rd.tax_code = 1 THEN 0.23 WHEN rd.tax_code = 4 THEN 0.135 ELSE 0.00 END) AS DECIMAL (18, 2)) AS price_before_discount,
       -- VAT Calculation (Centralized)
       ROUND(CAST (ISNULL(rd.sell_price, 0) AS DECIMAL (38, 6)) * CAST (ISNULL(rd.quantity, 0) AS DECIMAL (38, 6)) * CAST (CASE WHEN rd.tax_code = 1 THEN 0.23 WHEN rd.tax_code = 4 THEN 0.135 ELSE 0.00 END AS DECIMAL (38, 6)), 2) AS vat_amount,
       -- Discounts & Approvals
       rd.discount_approved_by AS discount_approver_id,
       ISNULL(rd.credited, 0) AS is_credited,
       NULLIF (TRIM(rd.credit_no), '') AS credit_number
FROM   [stg].[repairs_details] AS rd;