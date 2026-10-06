CREATE
-- OR ALTER
VIEW [dbo].[05 - Order Credits] AS
SELECT
    [transaction_key]             AS [Transaction Key],
    [credit_date]                 AS [Credit Date],
    [customer_code]               AS [Customer Code],
    [employee_key]                AS [Employee Key],
    [creditor_key]                AS [Creditor Key],
    [product_key]                   AS [Product Key],
    [quantity]                    AS [Quantity],
    [price]                       AS [Price],
    [vat_amount]                  AS [VAT Amount],
    [cost]                        AS [Cost],
    [price_before_discount]       AS [Price Before Discount],
    [approver_key]                AS [Approver Key],
    COALESCE([order_date], [credit_date]) AS [Order Date], -- fall back to credit date if order date is null
    [order_time]                  AS [Order Time],
    [is_dispatched]               AS [Is Dispatched],
    [invoice_connection_number]   AS [Invoice Connection Number],
    [web_order_id]                AS [Web Order ID],
    [line_sequence_number]        AS [Line Sequence Number],
    [description]                 AS [Description],
    [last_modified_datetime]      AS [Last Modified Datetime],
    [order_channel]               AS [Order Channel],
    [collection_employee_key]     AS [Collection Employee Key]
FROM [marts].[fct_order_credits]
