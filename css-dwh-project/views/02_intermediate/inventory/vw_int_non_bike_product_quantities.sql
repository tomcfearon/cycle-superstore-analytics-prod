CREATE
-- OR ALTER
VIEW [int].[non_bike_product_quantities] AS
WITH aggregated AS (
    SELECT
        m.product_key,
        s.location_name,
        SUM(s.quantity_on_hand) AS quantity_on_hand
    FROM
        [stg].[product_counted_locations] AS s
        INNER JOIN [int].[product_code_to_product_key_mapping] AS m ON m.product_id = s.product_id
    GROUP BY
        m.product_key,
        s.location_name
)
SELECT
    a.product_key,
    ISNULL(
        SUM(
            CASE
                WHEN a.location_name = 'T1' THEN a.quantity_on_hand
            END
        ),
        0
    ) AS quantity_on_hand_t1,
    ISNULL(
        SUM(
            CASE
                WHEN a.location_name = 'T2' THEN a.quantity_on_hand
            END
        ),
        0
    ) AS quantity_on_hand_t2,
    ISNULL(
        SUM(
            CASE
                WHEN a.location_name = 'Cara' THEN a.quantity_on_hand
            END
        ),
        0
    ) AS quantity_on_hand_cara
FROM
    aggregated AS a
GROUP BY
    a.product_key
