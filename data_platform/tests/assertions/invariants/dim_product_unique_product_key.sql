-- Product dimension records must have one row for each populated normalized product key.
IF EXISTS (
    SELECT [product_key]
    FROM [marts].[dim_product]
    WHERE [product_key] IS NOT NULL
    GROUP BY [product_key]
    HAVING COUNT(*) > 1
)
BEGIN
    THROW 52001, 'Assertion failed: dim_product.product_key has duplicate values', 1;
END;