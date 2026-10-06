CREATE VIEW -- OR ALTER
[int].[vw_int_service_product]
AS
WITH   SearchPatterns
AS     (-- Centralized list of patterns, categorized to keep the logic clean
        SELECT LOWER(pattern) AS pattern,
               category
        FROM   (VALUES -- 1. YOUR COMPANY BRANDS
               ('%giant%', 'Brand'), ('%gaint%', 'Brand'), ('%defy%', 'Brand'), ('%tcr%', 'Brand'), ('%propel%', 'Brand'), ('%look%', 'Brand'), ('%795 blade%', 'Brand'), ('%lapierre%', 'Brand'), ('%lapier%', 'Brand'), ('%cannondale%', 'Brand'), ('%canondale%', 'Brand'), ('%supersix%', 'Brand'), ('%caad%', 'Brand'), ('% cube %', 'Brand'), ('% cube', 'Brand'), ('cube %', 'Brand'), ('% gt %', 'Brand'), ('% gt', 'Brand'), ('gt %', 'Brand'), ('%raleigh%', 'Brand'), ('%raliegh%', 'Brand'), ('%rally%', 'Brand'), ('% drag %', 'Brand'), ('% drag', 'Brand'), ('drag %', 'Brand'), ('%brompton%', 'Brand'), ('%bromton%', 'Brand'), ('%pinarello%', 'Brand'), ('%pinerello%', 'Brand'), ('%whiback%', 'Brand'), ('%ridgeback%', 'Brand'), ('%whyte%', 'Brand'), -- 2. WHEELS (Including top brands in the Irish market)
               ('%wheel%', 'Wheel'), ('%wheelset%', 'Wheel'), ('% rim %', 'Wheel'), ('% rims %', 'Wheel'), ('%mavic%', 'Wheel'), ('%zipp%', 'Wheel'), ('%corima%', 'Wheel'), ('%enve%', 'Wheel'), ('% hunt %', 'Wheel'), ('%fulcrum racing%', 'Wheel'), ('%fulcrum rapid red%', 'Wheel'), ('%campagnolo shamal%', 'Wheel'), ('%campagnolo zonda%', 'Wheel'), ('%campagnolo bora%', 'Wheel'), ('%bontrager aeolus%', 'Wheel'), ('%bontrager paradigm%', 'Wheel'), -- 3. FORKS & SUSPENSION
               ('%fork%', 'Fork'), ('%suspension%', 'Fork'), ('%shock%', 'Fork'), ('%rockshox%', 'Fork'), ('%rock shox%', 'Fork'), ('%pike%', 'Fork'), ('%lyrik%', 'Fork'), ('%zeb%', 'Fork'), ('%reba%', 'Fork'), ('%boxxer%', 'Fork'), -- (Fox makes clothing, so we use specific keywords to avoid flagging a "Fox Racing Glove")
               ('%fox float%', 'Fork'), ('%fox factory%', 'Fork'), ('%fox 32%', 'Fork'), ('%fox 34%', 'Fork'), ('%fox 36%', 'Fork'), ('%fox 38%', 'Fork'), ('%fox 40%', 'Fork'), ('%marzocchi%', 'Fork'), ('%bomber z1%', 'Fork'), ('%bomber z2%', 'Fork'), ('%suntour%', 'Fork'), ('%manitou%', 'Fork'), ('%cane creek helm%', 'Fork'), ('%ohlins%', 'Fork'), ('%öhlins%', 'Fork'), -- 4. PEDALS
               ('%pedal%', 'Pedal'), ('%look keo%', 'Pedal'), ('%keo 2 max%', 'Pedal'), ('%keo blade%', 'Pedal'), ('%keo classic%', 'Pedal'), ('% spd %', 'Pedal'), ('%spd-sl%', 'Pedal'), ('%spd sl%', 'Pedal'), -- (Shimano makes everything, so we target their specific pedal model numbers and systems)
               ('%pd-r7000%', 'Pedal'), ('%pd-r8000%', 'Pedal'), ('%pd-m520%', 'Pedal'), ('%pd-m8100%', 'Pedal'), ('%speedplay%', 'Pedal'), ('%crankbrothers%', 'Pedal'), ('%crank brothers%', 'Pedal'), ('%eggbeater%', 'Pedal'), ('%stamp 3%', 'Pedal'), ('%stamp 7%', 'Pedal'), ('%favero assioma%', 'Pedal'), ('%time xpro%', 'Pedal'), ('%time xpresso%', 'Pedal')) AS t(pattern, category))
SELECT s.product_id,
       s.title,
       s.row_modified_datetime,
       NULLIF (s.model_year, '') AS model_year,
       NULLIF (s.brand, '') AS brand,
       -- Company Stock Logic: all rows here are SER- codes, so infer from brand field / title patterns only.
       CAST (CASE WHEN NULLIF (s.brand, '') IS NOT NULL THEN 1 WHEN EXISTS (SELECT 1
                                                                            FROM   SearchPatterns AS sp
                                                                            WHERE  sp.category = 'Brand'
                                                                                   AND LOWER(s.title) LIKE sp.pattern) THEN 1 ELSE 0 END AS BIT) AS is_company_stock,
       -- Wheel Logic
       CAST (CASE WHEN EXISTS (SELECT 1
                               FROM   SearchPatterns AS sp
                               WHERE  sp.category = 'Wheel'
                                      AND LOWER(s.title) LIKE sp.pattern) THEN 1 ELSE 0 END AS BIT) AS is_wheel,
       -- Fork/Suspension Logic
       CAST (CASE WHEN EXISTS (SELECT 1
                               FROM   SearchPatterns AS sp
                               WHERE  sp.category = 'Fork'
                                      AND LOWER(s.title) LIKE sp.pattern) THEN 1 ELSE 0 END AS BIT) AS is_fork,
       -- Pedal Logic
       CAST (CASE WHEN EXISTS (SELECT 1
                               FROM   SearchPatterns AS sp
                               WHERE  sp.category = 'Pedal'
                                      AND LOWER(s.title) LIKE sp.pattern) THEN 1 ELSE 0 END AS BIT) AS is_pedal
FROM   [stg].[product] AS s
WHERE  s.product_id LIKE 'SER-%'; -- Only SER-prefixed records need pattern inference; real bike codes are classified upstream in base_repair_header