CREATE
-- OR ALTER
VIEW [stg].[employees] AS
SELECT
    au.UserID AS employee_key,
    au.UserName AS employee_name,
    au.[Password] AS password,
    au.Active AS is_active,
    au.Bonus AS bonus,
    au.Note AS note,
    au.StartDate AS start_date,
    au.SwipeCard AS swipe_card,
    au.SaleTarget AS sale_target,
    NULLIF(TRIM(au.CustomerCode), '') AS customer_code,
    CASE
        WHEN au.Engineer IS NULL THEN 0
        WHEN TRY_CAST(au.Engineer AS int) = 0 THEN 0
        ELSE 1
    END AS is_engineer,
    au.EmpRefNo AS employee_reference_number,
    ROUND(au.BonusCollected, 2) AS bonus_from_collections,
    au.UseAllStockLocations AS use_all_stock_locations
FROM
        [raw_ccdata].[AdminUsers] AS au;
