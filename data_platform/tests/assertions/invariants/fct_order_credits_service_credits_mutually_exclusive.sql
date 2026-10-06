-- A credit line must never be classified as both a sales (order) credit and a service credit.
IF EXISTS (SELECT 1
           FROM   [marts].[fct_order_credits] AS oc
                  INNER JOIN
                  [marts].[fct_service_credits] AS sc
                  ON RIGHT(oc.[transaction_key], LEN(oc.[transaction_key]) - 8) = RIGHT(sc.[transaction_key], LEN(sc.[transaction_key]) - 8)) -- strip 'ORD-CRD-'/'SVC-CRD-' prefixes to compare the underlying credit_number
    BEGIN
        THROW 52011, 'Assertion failed: fct_order_credits and fct_service_credits contain overlapping credit numbers.', 1;
    END