CREATE VIEW --web product table
-- OR ALTER
[stg].[web_product]
AS
SELECT CAST ([idProduct] AS VARCHAR (100)) AS web_product_id,
       [description] AS web_title,
       [price] AS web_price,
       [listPrice] AS web_list_price,
       [bToBPrice] AS web_b2b_price,
       [stock] AS web_stock_qty,
       [listHidden] AS web_is_list_hidden,
       [active] AS web_is_active,
       [cost] AS web_cost_price,
       CAST ([pcprod_ParentPrd] AS VARCHAR (100)) AS web_parent_product_id,
       [pcprod_Relationship] AS web_product_relationship,
       [barcode] AS web_barcode,
       [isSale] AS web_is_sale,
       [isTradeSale] AS web_is_trade_sale,
       [supplierQty] AS web_supplier_qty,
       trim([sku]) AS stock_code
FROM   [raw_css2].[products] -- exclude parent rows (parent_product_id = 0); INT comparison keeps this sargable
WHERE  [pcprod_ParentPrd] <> 0
UNION ALL
-- Synthetic gift card rows: Google submits 'v-gift-{N}', ERP stock code is 'giftVoucher{N}'
SELECT CONCAT('v-gift-', CAST (d.price AS VARCHAR (10))) AS web_product_id,
       CONCAT('Cycle Superstore €', CAST (d.price AS VARCHAR (10)), ' Gift Card') AS web_title,
       CAST (d.price AS DECIMAL (10, 2)) AS web_price,
       CAST (d.price AS DECIMAL (10, 2)) AS web_list_price,
       NULL AS web_b2b_price,
       NULL AS web_stock_qty,
       0 AS web_is_list_hidden,
       1 AS web_is_active,
       0 AS web_cost_price,
       'v-gift' AS web_parent_product_id,
       NULL AS web_product_relationship,
       NULL AS web_barcode,
       0 AS web_is_sale,
       0 AS web_is_trade_sale,
       NULL AS web_supplier_qty,
       CONCAT('giftVoucher', CAST (d.price AS VARCHAR (10))) AS stock_code
FROM   (VALUES (20), (50), (100), (200), (500), (1000)) AS d(price);