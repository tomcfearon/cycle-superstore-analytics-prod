CREATE
-- OR ALTER
VIEW [dbo].[06 - Till Credits] AS
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
    [order_date]                  AS [Order Date],
    [order_time]                  AS [Order Time],
    [is_dispatched]               AS [Is Dispatched],
    [invoice_connection_number]   AS [Invoice Connection Number],
    [line_sequence_number]        AS [Line Sequence Number],
    [description]                 AS [Description],
    [last_modified_datetime]      AS [Last Modified Datetime],
    [order_channel]               AS [Order Channel],
    [is_from_invoice_note]        AS [Is From Invoice Note]
FROM [marts].[fct_till_credits]
