CREATE
-- OR ALTER
VIEW [int].[bike_product_quantities] AS
WITH filtered AS (
    SELECT
        s.stock_location,
        m.product_key
    FROM
        [stg].[product] AS s
        INNER JOIN [int].[product_code_to_product_key_mapping] AS m ON m.product_id = s.product_id
    WHERE
        s.item_type = 0                        -- Bikes only
        AND s.date_sold IS NULL                -- Exclude sold bikes
),
aggregated AS (
    SELECT
        f.product_key,
        f.stock_location,
        COUNT(*) AS quantity_on_hand
    FROM
        filtered AS f
    GROUP BY
        f.product_key,
        f.stock_location
)
SELECT
    a.product_key,
    SUM(
        CASE
            WHEN a.stock_location = 'T1' THEN a.quantity_on_hand
            ELSE 0
        END
    ) AS quantity_on_hand_t1,
    SUM(
        CASE
            WHEN a.stock_location = 'T2' THEN a.quantity_on_hand
            ELSE 0
        END
    ) AS quantity_on_hand_t2,
    SUM(
        CASE
            WHEN a.stock_location = 'Cara' THEN a.quantity_on_hand
            ELSE 0
        END
    ) AS quantity_on_hand_cara
FROM
    aggregated AS a
GROUP BY
    a.product_key;
