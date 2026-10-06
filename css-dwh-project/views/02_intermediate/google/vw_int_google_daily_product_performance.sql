CREATE
-- OR ALTER
VIEW [int].[vw_int_google_daily_product_performance]
AS
    -- Resolves Google Merchant Center product_id to warehouse product_key via two-step logic:
    --   1. Primary:  match on web_product_id (product is still active in consolidated_stock)
    --   2. Fallback: look up the product in stg.web_stock by web_product_id and match on
    --                stock_code — covers inactive/replaced products whose ERP record still
    --                exists but whose web_product_id was displaced by a newer active variant
    --                in the web_stock_integrated dedup
    -- NULL product_key is only expected for:
    --   • Products fully deleted from the website database (no stg.web_stock row exists)
    --   • Parent product IDs submitted to Google (should not appear in the MC feed)
    SELECT
        g.performance_date,
        g.product_id,
        CASE WHEN g.destination = 'ADS' THEN 'Ads'
        ELSE 'Organic' END AS destination,
        COALESCE(s_direct.product_key, s_sku.product_key) AS product_key,
        g.total_impressions,
        g.total_clicks
    FROM [stg].[google_daily_product_performance] AS g
        LEFT JOIN [int].[consolidated_product] AS s_direct
            ON s_direct.web_product_id = g.product_id
        LEFT JOIN [stg].[web_product] AS w
            ON CAST(w.web_product_id AS varchar(20)) = g.product_id
        LEFT JOIN [int].[consolidated_product] AS s_sku
            ON s_sku.stock_code = w.stock_code
