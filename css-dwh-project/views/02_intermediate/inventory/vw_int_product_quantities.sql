CREATE
-- OR ALTER
VIEW [int].[product_quantities] AS
SELECT
    product_key,
    sum(quantity_on_hand_t1) AS quantity_on_hand_t1,
    sum(quantity_on_hand_t2) AS quantity_on_hand_t2,
    sum(quantity_on_hand_cara) AS quantity_on_hand_cara
FROM
    (
        SELECT
            product_key,
            quantity_on_hand_t1,
            quantity_on_hand_t2,
            quantity_on_hand_cara
        FROM
            [int].[bike_product_quantities]
        UNION
        ALL
        SELECT
            product_key,
            quantity_on_hand_t1,
            quantity_on_hand_t2,
            quantity_on_hand_cara
        FROM
            [int].[non_bike_product_quantities]
    ) AS combined
GROUP BY
    product_key
    HAVING SUM(quantity_on_hand_cara) > 0
    OR SUM(quantity_on_hand_t1) > 0
    OR SUM(quantity_on_hand_t2) > 0
