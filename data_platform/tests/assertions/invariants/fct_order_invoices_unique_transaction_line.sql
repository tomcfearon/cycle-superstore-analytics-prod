-- Each order-invoice transaction may contain one row per source line sequence only.
IF EXISTS (
    SELECT [transaction_key], [line_sequence_number]
    FROM [marts].[fct_order_invoices]
    GROUP BY [transaction_key], [line_sequence_number]
    HAVING COUNT(*) > 1
)
BEGIN
    THROW 52010, 'Assertion failed: fct_order_invoices contains duplicate transaction and line-sequence pairs.', 1;
END;