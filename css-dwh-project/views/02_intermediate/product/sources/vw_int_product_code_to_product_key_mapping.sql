-- Centralised ERP product-code normalisation used to refresh the physical lookup table.
CREATE
-- OR ALTER
VIEW [int].[vw_int_product_code_to_product_key_mapping]
AS
-- 1. Define CleanedStock once for all mapping branches.
--
--    The former procedure materialised this data in a #temp table to avoid
--    scanning stock twice and to support Branch C's anti-join. Keeping the
--    derivation here makes the business logic reusable outside the loader.
--
--    product_key derivation uses REVERSE to locate the LAST dash, preserving
--    multi-segment model numbers. Both bike (-1-) and frame (-0-) codes
--    normalise to a '-1' suffix.
--
--    Example: 'C1609271159-27023-1-158996' (a Pinarello)
--      Old (broken) formula: LEFT(stockcode, CHARINDEX('-', stockcode)-1) + '-1'
--        = 'C1609271159' + '-1'   <-- strips at FIRST dash, wrong model
--      Correct formula (REVERSE):
--        LEN=26, CHARINDEX('-', REVERSE(stockcode))=7, so LEFT(26-7-2=17) + '-1'
--        = 'C1609271159-27023' + '-1'   <-- correct
WITH   cleaned_product
AS     (SELECT p.product_id,
               -- stock_code is the ERP model number (ModelNo), not a truncated product ID.
               -- For individual bike units product_id contains the serial-embedded code,
               -- while stock_code retains the model number.
               p.stock_code,
               p.row_modified_datetime, -- Added timestamp
               -- product_key strips the final serial segment and normalises bike/frame items.
               --
               -- Guard: product_id <> stock_code identifies genuine bike/frame serial codes.
               -- Sundry items, including ISBNs containing '-0-' or '-1-', have matching
               -- values and must not be reclassified.
               --
               -- Example: 'C1609271159-27023-1-158996' becomes 'C1609271159-27023-1'.
               --
               -- Box items such as 'HI5EGAQCFBR-BOX' use their stocked SINGLE counterpart
               -- key so sales of boxes and individual units roll up to the same product.
               CASE -- Serialised bikes and frames retain their full model number and normalise to '-1'.
               WHEN p.product_id <> p.stock_code
                    AND (p.product_id LIKE '%-1-%'
                         OR p.product_id LIKE '%-0-%') THEN LEFT(p.product_id, LEN(p.product_id) - CHARINDEX('-', REVERSE(p.product_id)) - 2) + '-1' WHEN p.product_id LIKE '%-BOX' -- Box products roll up to a stocked single-item key when one exists.
                                                                                                                                                          AND EXISTS (SELECT 1
                                                                                                                                                                      FROM   [stg].[product] AS single_product
                                                                                                                                                                      WHERE  single_product.product_id = LEFT(p.product_id, LEN(p.product_id) - CHARINDEX('-', REVERSE(p.product_id))) + '-SINGLE'
                                                                                                                                                                             AND single_product.product_id NOT LIKE 'SER-1-%') THEN LEFT(p.product_id, LEN(p.product_id) - CHARINDEX('-', REVERSE(p.product_id))) + '-SINGLE-0' ELSE -- Non-bike items retain their source code and receive the '-0' suffix.
               p.product_id + '-0' END AS product_key
        FROM   [stg].[product] AS p
        WHERE  p.product_id NOT LIKE 'SER-1-%'),
       mapping
AS     (-- 2. Return one row per product_id with no aggregation so invoice lookups match.
        -- Every individual stock item, including serialised units, needs a lookup row.
        SELECT c.product_key,
               c.product_id,
               c.stock_code,
               c.row_modified_datetime
        FROM   cleaned_product AS c
        UNION ALL
        -- System placeholders use the reserved '-3' product-key suffix.
        SELECT v.product_key,
               v.product_id,
               v.stock_code,
               CAST ('1900-01-01' AS DATETIME) AS row_modified_datetime
        FROM   (VALUES ('MISC-3', 'MISC', 'MISC'), ('SWAP-3', 'SWAP', 'SWAP'), ('DISC-3', 'DISC', 'DISC'), ('OrderMain-3', 'OrderMain', 'OrderMain')) AS v(product_key, product_id, stock_code)
        UNION ALL
        -- Bike models without stock rows cover trade-ins that have no individual stock unit.
        -- The first guard prevents duplicate product keys; the second prevents Branch C
        -- from duplicating a product ID already represented by a stock_code in Branch A.
        SELECT bs.product_key,
               bs.stock_code AS product_id,
               bs.stock_code,
               bs.row_modified_datetime
        FROM   [stg].[bike_product] AS bs
        WHERE  NOT EXISTS (SELECT 1
                           FROM   cleaned_product AS c
                           WHERE  c.product_key = bs.product_key)
               AND NOT EXISTS (SELECT 1
                               FROM   cleaned_product AS c
                               WHERE  c.product_id = bs.stock_code)
               AND LOWER(bs.stock_code) NOT IN ('misc', 'swap', 'disc', 'ordermain'))
SELECT CAST (m.product_key AS VARCHAR (52)) AS product_key,
       CAST (m.product_id AS VARCHAR (52)) AS product_id,
       CAST (m.stock_code AS VARCHAR (52)) AS stock_code,
       CAST (m.row_modified_datetime AS DATETIME) AS row_modified_datetime
FROM   mapping AS m;