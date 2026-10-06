-- Query text for the ADF daily product-price snapshot.
-- Mirrors the source-side inventory snapshot product universe so prices are saved for the same product keys.
WITH

-- Inline the warehouse product-key mapping so source snapshots stay aligned with dim_product keys.
stock_map AS (
    SELECT
        s.StockCode AS product_id,
        CASE
            WHEN s.StockCode <> s.ModelNo
                 AND (s.StockCode LIKE '%-1-%' OR s.StockCode LIKE '%-0-%')
            THEN LEFT(
                     s.StockCode,
                     LEN(s.StockCode) - CHARINDEX('-', REVERSE(s.StockCode)) - 2
                 ) + '-1'
            WHEN s.StockCode LIKE '%-BOX'
                 AND EXISTS (
                     SELECT 1
                     FROM dbo.Stock AS s2
                     WHERE s2.StockCode = LEFT(
                               s.StockCode,
                               LEN(s.StockCode) - CHARINDEX('-', REVERSE(s.StockCode))
                           ) + '-SINGLE'
                       AND s2.StockCode NOT LIKE 'SER-1-%'
                 )
            THEN LEFT(
                     s.StockCode,
                     LEN(s.StockCode) - CHARINDEX('-', REVERSE(s.StockCode))
                 ) + '-SINGLE-0'
            ELSE s.StockCode + '-0'
        END AS product_key
    FROM dbo.Stock AS s
    WHERE s.StockCode NOT LIKE 'SER-1-%'
),

-- Rebuild the inventory scope first so the price snapshot covers the same product keys as the daily inventory save.
bike_qty AS (
    SELECT
        m.product_key,
        s.StockLocation AS location_name,
        COUNT(*) AS quantity_on_hand
    FROM dbo.Stock AS s
    INNER JOIN stock_map AS m ON m.product_id = s.StockCode
    WHERE s.ItemType = 0
      AND s.DateSold IS NULL
    GROUP BY m.product_key, s.StockLocation
),

-- Sundry quantities come from counted locations, excluding BOX rows just like the inventory snapshot.
sundry_qty AS (
    SELECT
        m.product_key,
        sc.StockLocation AS location_name,
        SUM(sc.QtyOnHand) AS quantity_on_hand
    FROM dbo.StockCountedLocations AS sc
    INNER JOIN stock_map AS m ON m.product_id = sc.StockCode
    WHERE sc.StockCode NOT LIKE '%-BOX'
    GROUP BY m.product_key, sc.StockLocation
),

combined AS (
    SELECT product_key, location_name, quantity_on_hand FROM bike_qty
    UNION ALL
    SELECT product_key, location_name, quantity_on_hand FROM sundry_qty
),

-- Keep only product keys that the inventory snapshot would actually emit.
inventory_scope AS (
    SELECT
        c.product_key
    FROM combined AS c
    GROUP BY c.product_key
    HAVING
        SUM(CASE WHEN c.location_name = 'T1' THEN c.quantity_on_hand ELSE 0 END) > 0
        OR SUM(CASE WHEN c.location_name = 'T2' THEN c.quantity_on_hand ELSE 0 END) > 0
        OR SUM(CASE WHEN c.location_name = 'Cara' THEN c.quantity_on_hand ELSE 0 END) > 0
),

-- Bike price candidates are taken from live unsold stock rows so they match the bike inventory branch.
bike_price_candidates AS (
    SELECT
        m.product_key,
        s.StockCode AS product_id,
        s.ModelNo AS stock_code,
        s.RetailPrice AS rrp_price,
        s.CostPrice AS cost_price,
        s.SellingPrice1 AS selling_price_1,
        s.SellingPrice3 AS selling_price_3,
        s.SellingPrice5 AS selling_price_5,
        s.SellingPrice7 AS selling_price_7,
        s.TradePrice AS trade_price,
        'bike' AS source_branch
    FROM dbo.Stock AS s
    INNER JOIN stock_map AS m ON m.product_id = s.StockCode
    WHERE s.ItemType = 0
      AND s.DateSold IS NULL
),

-- Sundry price candidates are restricted to counted-location stock codes so the branch matches non-bike inventory.
sundry_price_candidates AS (
    SELECT DISTINCT
        m.product_key,
        s.StockCode AS product_id,
        s.ModelNo AS stock_code,
        s.RetailPrice AS rrp_price,
        s.CostPrice AS cost_price,
        s.SellingPrice1 AS selling_price_1,
        s.SellingPrice3 AS selling_price_3,
        s.SellingPrice5 AS selling_price_5,
        s.SellingPrice7 AS selling_price_7,
        s.TradePrice AS trade_price,
        'sundry' AS source_branch
    FROM dbo.StockCountedLocations AS sc
    INNER JOIN stock_map AS m ON m.product_id = sc.StockCode
    INNER JOIN dbo.Stock AS s ON s.StockCode = sc.StockCode
    WHERE sc.StockCode NOT LIKE '%-BOX'
),

price_candidates AS (
    SELECT
        product_key,
        product_id,
        stock_code,
        rrp_price,
        cost_price,
        selling_price_1,
        selling_price_3,
        selling_price_5,
        selling_price_7,
        trade_price,
        source_branch
    FROM bike_price_candidates

    UNION ALL

    SELECT
        product_key,
        product_id,
        stock_code,
        rrp_price,
        cost_price,
        selling_price_1,
        selling_price_3,
        selling_price_5,
        selling_price_7,
        trade_price,
        source_branch
    FROM sundry_price_candidates
),

-- Rank duplicates so each product key keeps one stable source row for the daily snapshot.
ranked_prices AS (
    SELECT
        i.product_key,
        pc.rrp_price,
        pc.cost_price,
        pc.selling_price_1,
        pc.selling_price_3,
        pc.selling_price_5,
        pc.selling_price_7,
        pc.trade_price,
        ROW_NUMBER() OVER (
            PARTITION BY i.product_key
            ORDER BY
                CASE WHEN pc.source_branch = 'sundry' THEN 0 ELSE 1 END,
                CASE WHEN pc.product_id = pc.stock_code THEN 0 ELSE 1 END,
                pc.product_id
        ) AS row_num
    FROM inventory_scope AS i
    INNER JOIN price_candidates AS pc ON pc.product_key = i.product_key
)

SELECT
    rp.product_key,
    rp.rrp_price,
    rp.cost_price,
    rp.selling_price_1,
    rp.selling_price_3,
    rp.selling_price_5,
    rp.selling_price_7,
    rp.trade_price,
    CAST(GETDATE() AS DATE) AS query_date,
    GETDATE() AS query_datetime
FROM ranked_prices AS rp
WHERE rp.row_num = 1
ORDER BY rp.product_key;