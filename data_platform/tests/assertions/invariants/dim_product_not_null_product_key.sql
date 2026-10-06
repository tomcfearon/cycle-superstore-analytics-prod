-- Product dimension records require the normalized product key.
IF EXISTS (SELECT 1
           FROM   [marts].[dim_product]
           WHERE  [product_key] IS NULL)
    BEGIN
        THROW 52000, 'Assertion failed: dim_product.product_key contains NULL values', 1;
    END