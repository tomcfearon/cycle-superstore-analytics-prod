CREATE
-- OR ALTER
VIEW [dbo].[12 - Purchase Orders] AS
SELECT
    [product_key]                       AS [Product Key],
    [order_number]                    AS [Order Number],
    [order_date]                      AS [Document Date],
    [due_in_date]                     AS [Due In Date],
    [goods_in_datetime]               AS [Goods In Datetime],
    [supplier_code]                   AS [Supplier Code],
    [purchase_order_employee_key]     AS [Purchase Order Employee Key],
    [goods_in_employee_key]           AS [Goods In Employee Key],
    [line_number]                     AS [Line Number],
    [item_type]                       AS [Item Type],
    [stock_location]                  AS [Stock Location],
    [quantity]                        AS [Quantity],
    [quantity_received]               AS [Quantity Received],
    [cost]                            AS [Cost],
    [retail_price]                    AS [Retail Price],
    [trade_price]                     AS [Trade Price]
FROM [marts].[fct_purchase_orders]
