CREATE
-- OR ALTER
VIEW [dbo].[07 - Service Credits] AS
SELECT
    [transaction_key]               AS [Transaction Key],
    [credit_date]                   AS [Credit Date],
    [credit_time]                   AS [Credit Time],
    COALESCE([order_date], [credit_date]) AS [Order Date], -- fall back to credit date if no linked service order
    [customer_code]                 AS [Customer Code],
    [salesperson_employee_key]      AS [Salesperson Key],
    [engineer_key]                  AS [Engineer Key],
    [creditor_key]                  AS [Creditor Key],
    [approver_key]                  AS [Approver Key],
    [invoice_connection_number]     AS [Invoice Connection Number],
    [order_number]                  AS [Order Number],
    [web_order_id]                  AS [Web Order ID],
    [last_modified_datetime]        AS [Last Modified Datetime],
    [product_key]                   AS [Product Key],
    [description]                   AS [Description],
    [line_sequence_number]          AS [Line Sequence Number],
    [quantity]                      AS [Quantity],
    [price_before_discount]         AS [Price Before Discount],
    [price]                         AS [Price],
    [vat_amount]                    AS [VAT Amount],
    [cost]                          AS [Cost],
    [order_channel]                 AS [Order Channel],
    [service_type_key]              AS [Service Type Key]
FROM [marts].[fct_service_credits]
