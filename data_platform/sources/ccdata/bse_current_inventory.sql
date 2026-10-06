

--SCRIPT IS RUN INSIDE ADF PIPELINE, DO NOT ALTER VIEW TO TRY CHANGE EFFECT


-- XPT.current_inventory_2
-- Combines bike and non-bike stock into a single current-inventory view.
-- Replicates the exact logic of int.stock_quantities in the warehouse:
--   int.bike_stock_quantities      → Branch A (bikes)
--   int.non_bike_stock_quantities  → Branch B (sundry)
--
-- stock_key derivation is inlined from int.stock_code_to_stock_key_mapping.
CREATE OR ALTER VIEW [XPT].[current_inventory_2] AS
WITH

-- ──────────────────────────────────────────────────────
-- STOCK KEY MAPPING (inlined from int.stock_code_to_stock_key_mapping)
-- One row per StockCode in dbo.Stock, excluding SER-1-%.
-- The CASE mirrors the warehouse mapping loader:
--   - Bikes/frames (StockCode ≠ ModelNo + serial pattern) → strip serial → '-1'
--   - BOX items with a SINGLE counterpart → '-SINGLE-0'
--   - Everything else (sundry) → StockCode + '-0'
-- ──────────────────────────────────────────────────────
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
        END AS stock_key
    FROM dbo.Stock AS s
    WHERE s.StockCode NOT LIKE 'SER-1-%'
),

-- ──────────────────────────────────────────────────────
-- BRANCH A: Bikes — COUNT physical units in dbo.Stock
-- Replicates int.bike_stock_quantities:
--   item_type = 0, date_sold IS NULL, INNER JOIN mapping.
-- ──────────────────────────────────────────────────────
bike_qty AS (
    SELECT
        m.stock_key,
        s.StockLocation    AS location_name,
        COUNT(*)           AS quantity_on_hand
    FROM dbo.Stock AS s
    INNER JOIN stock_map AS m ON m.product_id = s.StockCode
    WHERE s.ItemType = 0
      AND s.DateSold IS NULL
    GROUP BY m.stock_key, s.StockLocation
),

-- ──────────────────────────────────────────────────────
-- BRANCH B: Non-bikes — SUM QtyOnHand from StockCountedLocations
-- Replicates int.non_bike_stock_quantities:
--   stg.stock_counted_locations (excludes %-BOX) INNER JOIN mapping.
-- ──────────────────────────────────────────────────────
sundry_qty AS (
    SELECT
        m.stock_key,
        sc.StockLocation   AS location_name,
        SUM(sc.QtyOnHand)  AS quantity_on_hand
    FROM dbo.StockCountedLocations AS sc
    INNER JOIN stock_map AS m ON m.product_id = sc.StockCode
    WHERE sc.StockCode NOT LIKE '%-BOX'
    GROUP BY m.stock_key, sc.StockLocation
),

-- ──────────────────────────────────────────────────────
-- COMBINED: replicates int.stock_quantities
-- ──────────────────────────────────────────────────────
combined AS (
    SELECT stock_key, location_name, quantity_on_hand FROM bike_qty
    UNION ALL
    SELECT stock_key, location_name, quantity_on_hand FROM sundry_qty
)

SELECT
    c.stock_key,
    ISNULL(SUM(CASE WHEN c.location_name = 'T1'   THEN c.quantity_on_hand END), 0) AS quantity_on_hand_t1,
    ISNULL(SUM(CASE WHEN c.location_name = 'T2'   THEN c.quantity_on_hand END), 0) AS quantity_on_hand_t2,
    ISNULL(SUM(CASE WHEN c.location_name = 'Cara' THEN c.quantity_on_hand END), 0) AS quantity_on_hand_cara
FROM combined AS c
GROUP BY c.stock_key
HAVING
    SUM(CASE WHEN c.location_name = 'T1'   THEN c.quantity_on_hand ELSE 0 END) > 0
    OR SUM(CASE WHEN c.location_name = 'T2'   THEN c.quantity_on_hand ELSE 0 END) > 0
    OR SUM(CASE WHEN c.location_name = 'Cara' THEN c.quantity_on_hand ELSE 0 END) > 0;
GO
