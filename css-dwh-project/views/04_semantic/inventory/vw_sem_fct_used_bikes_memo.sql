CREATE
-- OR ALTER
VIEW [dbo].[04 - Used Bikes] AS
SELECT
    [used_bike_id]              AS [Used Bike ID],
    [service_order_number]      AS [Service Order Number],
    [web_bike_id]               AS [Web Bike ID],
    [memo_date]                 AS [Memo Date],
    [sold_date]                 AS [Sold Date],
    [customer_code]             AS [Customer Code],
    [sold_customer_code]        AS [Sold Customer Code],
    [salesperson1_key]          AS [Salesperson1 Key],
    [salesperson2_key]          AS [Salesperson2 Key],
    [sold_salesperson_key]      AS [Sold Salesperson Key],
    [description]               AS [Description],
    [brand]                     AS [Brand],
    [product_key]                 AS [Product Key],
    [retail_price]              AS [Retail Price],
    [cost_price]                AS [Cost Price],
    [sale_price]                AS [Sale Price],
    [sold_price]                AS [Sold Price],
    [sold_payment_amount]       AS [Sold Payment Amount],
    [service_cost_price]        AS [Service Cost Price],
    [used_bike_status]          AS [Used Bike Status],
    [used_bike_category]        AS [Used Bike Category],
    [web_status]                AS [Web Status],
    [order_channel]             AS [Order Channel]
FROM [marts].[fct_used_bikes_memo]