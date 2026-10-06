CREATE
-- OR ALTER
VIEW [dbo].[08 - Sales Order] AS
SELECT
    [transaction_key]             AS [Transaction Key],
    [order_date]                  AS [Order Date],
    [order_time]                  AS [Order Time],
    [customer_code]               AS [Customer Code],
    [employee_key]                AS [Employee Key],
    [collection_employee_key]     AS [Collection Employee Key],
    [product_key]                   AS [Product Key],
    [quantity]                    AS [Quantity],
    [price]                       AS [Price],
    [vat_amount]                  AS [VAT Amount],
    [cost]                        AS [Cost],
    [price_before_discount]       AS [Price Before Discount],
    [quantity_taken]              AS [Quantity Taken],
    [approver_key]                AS [Approver Key],
    [deposit_value]               AS [Deposit Value],
    [payment_to_date]             AS [Payment To Date],
    [collection_date]             AS [Collection Date],
    [order_status]                AS [Order Status],
    [web_order_id]                AS [Web Order ID],
    [is_confirmed]                AS [Is Confirmed],
    [bike_location]               AS [Bike Location],
    [box_number]                  AS [Box Number],
    [line_sequence_number]        AS [Line Sequence Number],
    [description]                 AS [Description],
    [request_id]                  AS [Request ID],
    [is_pulled]                   AS [Is Pulled],
    [order_channel]               AS [Order Channel]
FROM [marts].[fct_sales_orders]
