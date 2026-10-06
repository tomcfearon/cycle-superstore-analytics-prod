CREATE VIEW -- OR ALTER
[int].[purchase_orders]
AS
-- Dedupe employees by name to prevent LEFT JOIN fan-out (see vw_int_fact_repair_lines.sql).
WITH   deduped_employees
AS     (SELECT employee_key,
               employee_name,
               ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY employee_key DESC) AS rn
        FROM   [int].[employees])
SELECT -- stg.purchase_order_details.stock_code = ERP ModelNo (model-level code).
       -- Primary join on mapping.product_id handles sundry items (ModelNo = StockCode).
       -- Fallback join on mapping.stock_code handles bike models where the mapping only
       -- has serial-level product_id rows and the model code lives in stock_code.
       ISNULL(COALESCE (m.product_key, m_sc.product_key), 'MISC-3') AS product_key,
       h.order_no AS order_number,
       CAST (h.order_date AS DATE) AS order_date,
       CAST (h.due_in_date AS DATE) AS due_in_date,
       CAST (h.goods_in_date AS DATETIME) AS goods_in_datetime,
       h.supplier_code,
       ISNULL(e_po.employee_key, -1) AS purchase_order_employee_key,
       ISNULL(e_gi.employee_key, -1) AS goods_in_employee_key,
       d.line_no AS line_number,
       d.item_type,
       d.stock_location,
       d.qty AS quantity,
       d.qty_received AS quantity_received,
       d.cost,
       d.retail_price,
       d.trade_price
FROM   [stg].[purchase_order_header] AS h
       INNER JOIN
       [stg].[purchase_order_details] AS d
       ON h.order_no = d.order_no
       LEFT OUTER JOIN
       deduped_employees AS e_po
       ON h.salesperson = e_po.employee_name
          AND e_po.rn = 1
       LEFT OUTER JOIN
       deduped_employees AS e_gi
       ON h.goods_in_salesperson = e_gi.employee_name
          AND e_gi.rn = 1
       -- Primary: exact stock_code match (works for sundry where ModelNo = StockCode)
       LEFT OUTER JOIN
       [int].[product_code_to_product_key_mapping] AS m
       ON m.product_id = d.stock_code
       -- Fallback: model-code match via stock_code column (works for bike models where
       -- PO stores ModelNo but mapping only has serial-level product_id rows in Branch A)
       LEFT OUTER JOIN
       (SELECT   stock_code,
                 MIN(product_key) AS product_key
        FROM     [int].[product_code_to_product_key_mapping]
        GROUP BY stock_code) AS m_sc
       ON m_sc.stock_code = d.stock_code
WHERE  h.trans_type = 1;