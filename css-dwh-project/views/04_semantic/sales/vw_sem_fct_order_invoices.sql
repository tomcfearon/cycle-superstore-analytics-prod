CREATE
-- OR ALTER
VIEW [dbo].[01 - Order Invoices] AS
SELECT
    [transaction_key]             AS [Transaction Key],
    [invoice_date]                AS [Invoice Date],
    [customer_code]               AS [Customer Code],
    [employee_key]                AS [Employee Key],
    [collection_employee_key]     AS [Collection Employee Key],
    [creditor_key]                AS [Creditor Key],
    [product_key]                   AS [Product Key],
    [quantity]                    AS [Quantity],
    [price]                       AS [Price],
    [vat_amount]                  AS [VAT Amount],
    [cost]                        AS [Cost],
    [price_before_discount]       AS [Price Before Discount],
    [approver_key]                AS [Approver Key],
    [order_date]                  AS [Order Date],
    [order_time]                  AS [Order Time],
    [invoice_connection_number]   AS [Invoice Connection Number],
    [web_order_id]                AS [Web Order ID],
    [line_sequence_number]        AS [Line Sequence Number],
    [description]                 AS [Description],
    [row_modified_datetime]      AS [Last Modified Datetime],
    [is_dispatched]               AS [Is Dispatched],
    [is_used_bike_invoice]        AS [Is Used Bike Invoice],
    [order_channel]               AS [Order Channel],
    [is_credited]                 AS [Is Credited]
FROM [marts].[fct_order_invoices]
