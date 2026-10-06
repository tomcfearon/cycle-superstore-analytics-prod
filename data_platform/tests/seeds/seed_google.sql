SET NOCOUNT ON;

SET XACT_ABORT ON;

-- Refuse fixture writes outside the dedicated integration-test database.
IF DB_NAME() <> N'css-dwh-test'
    BEGIN
        THROW 52180, 'Google seed refused: the current database is not css-dwh-test.', 1;
    END

-- Require all Google raw tables to be empty before seeding deterministic marketing fixtures.
IF EXISTS (SELECT 1
           FROM   [raw_google].[ads_AccountBasicStats_5605924582])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[ads_AccountConversionStats_5605924582])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[ads_AccountStats_5605924582])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[ads_AssetGroup_5605924582])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[ads_BudgetStats_5605924582])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[ads_CampaignConversionStats_5605924582])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[ads_CampaignLabel_5605924582])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[ads_CampaignStats_5605924582])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[LocalInventories_131845897])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[PriceCompetitiveness_131845897])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[PriceInsights_131845897])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[vw_daily_product_performance])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[vw_PriceCompetitiveness])
   OR EXISTS (SELECT 1
              FROM   [raw_google].[vw_PriceInsights])
    BEGIN
        THROW 52181, 'Google seed refused: fixture tables are not empty. Run reset_test_database.sql first.', 1;
    END

BEGIN TRANSACTION;

-- Seed a deterministic Google Ads account before its account-level performance rows.
INSERT  INTO [raw_google].[ads_AccountBasicStats_5605924582] (
    [customer_id],
    [metrics_clicks],
    [metrics_conversions],
    [metrics_conversions_value],
    [metrics_cost_micros],
    [metrics_impressions],
    [segments_date],
    [_LATEST_DATE],
    [_DATA_DATE]
)
VALUES                                                      (5605924582, 10, 1.0, 120.0, 25000000, 1000, '2026-01-15T00:00:00', '2026-01-15T00:00:00', '2026-01-15T00:00:00');

INSERT  INTO [raw_google].[ads_AccountConversionStats_5605924582] (
    [customer_id],
    [metrics_conversions],
    [metrics_conversions_value],
    [metrics_value_per_conversion],
    [segments_conversion_action],
    [segments_conversion_action_name],
    [segments_date],
    [_LATEST_DATE],
    [_DATA_DATE]
)
VALUES                                                           (5605924582, 1.0, 120.0, 120.0, N'customers/5605924582/conversionActions/1', N'Synthetic conversion', '2026-01-15T00:00:00', '2026-01-15T00:00:00', '2026-01-15T00:00:00');

INSERT  INTO [raw_google].[ads_AccountStats_5605924582] (
    [customer_id],
    [metrics_clicks],
    [metrics_conversions],
    [metrics_conversions_value],
    [metrics_cost_micros],
    [metrics_impressions],
    [segments_date],
    [_LATEST_DATE],
    [_DATA_DATE]
)
VALUES                                                 (5605924582, 10, 1.0, 120.0, 25000000, 1000, '2026-01-15T00:00:00', '2026-01-15T00:00:00', '2026-01-15T00:00:00');

-- Seed a campaign label before the campaign-level performance and conversion facts reference it.
INSERT  INTO [raw_google].[ads_CampaignLabel_5605924582] (
    [campaign_id],
    [label_id],
    [campaign_label_campaign],
    [campaign_label_label],
    [campaign_name],
    [label_name],
    [_LATEST_DATE],
    [_DATA_DATE]
)
VALUES                                                  (700001, 710001, N'customers/5605924582/campaigns/700001', N'customers/5605924582/labels/710001', N'Synthetic test campaign', N'Integration Test', '2026-01-15T00:00:00', '2026-01-15T00:00:00');

INSERT  INTO [raw_google].[ads_CampaignStats_5605924582] (
    [campaign_id],
    [customer_id],
    [campaign_base_campaign],
    [metrics_clicks],
    [metrics_conversions],
    [metrics_conversions_value],
    [metrics_cost_micros],
    [metrics_impressions],
    [segments_date],
    [_LATEST_DATE],
    [_DATA_DATE]
)
VALUES                                                  (700001, 5605924582, N'customers/5605924582/campaigns/700001', 10, 1.0, 120.0, 25000000, 1000, '2026-01-15T00:00:00', '2026-01-15T00:00:00', '2026-01-15T00:00:00');

INSERT  INTO [raw_google].[ads_CampaignConversionStats_5605924582] (
    [campaign_id],
    [customer_id],
    [campaign_base_campaign],
    [metrics_conversions],
    [metrics_conversions_value],
    [metrics_value_per_conversion],
    [segments_conversion_action],
    [segments_conversion_action_name],
    [segments_date],
    [_LATEST_DATE],
    [_DATA_DATE]
)
VALUES                                                            (700001, 5605924582, N'customers/5605924582/campaigns/700001', 1.0, 120.0, 120.0, N'customers/5605924582/conversionActions/1', N'Synthetic conversion', '2026-01-15T00:00:00', '2026-01-15T00:00:00', '2026-01-15T00:00:00');

INSERT  INTO [raw_google].[ads_BudgetStats_5605924582] (
    [campaign_budget_id],
    [campaign_id],
    [customer_id],
    [campaign_name],
    [campaign_status],
    [metrics_clicks],
    [metrics_conversions],
    [metrics_cost_micros],
    [metrics_impressions],
    [segments_date],
    [_LATEST_DATE],
    [_DATA_DATE]
)
VALUES                                                (720001, 700001, 5605924582, N'Synthetic test campaign', N'ENABLED', 10, 1.0, 25000000, 1000, '2026-01-15T00:00:00', '2026-01-15T00:00:00', '2026-01-15T00:00:00');

INSERT  INTO [raw_google].[ads_AssetGroup_5605924582] (
    [asset_group_id],
    [asset_group_campaign],
    [asset_group_name],
    [asset_group_status],
    [_LATEST_DATE],
    [_DATA_DATE]
)
VALUES                                               (N'730001', N'customers/5605924582/campaigns/700001', N'Synthetic asset group', N'ENABLED', '2026-01-15T00:00:00', '2026-01-15T00:00:00');

-- Seed product marketing records with the same deterministic offer identifier.
INSERT  INTO [raw_google].[LocalInventories_131845897] (
    [_DATA_DATE],
    [product_id],
    [merchant_id],
    [aggregator_id],
    [store_code],
    [price],
    [availability],
    [quantity]
)
VALUES                                                ('2026-01-15T00:00:00', N'TEST-PROD-1', 131845897, 1, N'TEST-STORE', N'120.00 GBP', N'in stock', 5);

INSERT  INTO [raw_google].[PriceCompetitiveness_131845897] (
    [partition_date],
    [aggregator_id],
    [merchant_id],
    [id],
    [title],
    [brand],
    [offer_id],
    [report_country_code],
    [price],
    [benchmark_price]
)
VALUES                                                    ('2026-01-15', 1, 131845897, N'TEST-PROD-1', N'Synthetic product', N'Test Brand', N'TEST-PROD-1', N'GB', N'120.00 GBP', N'125.00 GBP');

INSERT  INTO [raw_google].[PriceInsights_131845897] (
    [partition_date],
    [aggregator_id],
    [merchant_id],
    [id],
    [title],
    [brand],
    [price],
    [suggested_price],
    [offer_id]
)
VALUES                                             ('2026-01-15', 1, 131845897, N'TEST-PROD-1', N'Synthetic product', N'Test Brand', N'120.00 GBP', N'118.00 GBP', N'TEST-PROD-1');

INSERT  INTO [raw_google].[vw_daily_product_performance] (
    [partition_date],
    [offer_id],
    [destination],
    [total_impressions],
    [total_clicks]
)
VALUES                                                  ('2026-01-15', N'TEST-PROD-1', N'Shopping', 1000, 10);

INSERT  INTO [raw_google].[vw_PriceCompetitiveness] (
    [partition_date],
    [aggregator_id],
    [merchant_id],
    [id],
    [title],
    [brand],
    [offer_id],
    [report_country_code],
    [price_value],
    [price_currency],
    [benchmark_price_value],
    [benchmark_price_currency]
)
VALUES                                             ('2026-01-15', 1, 131845897, N'TEST-PROD-1', N'Synthetic product', N'Test Brand', N'TEST-PROD-1', N'GB', 120.0000, N'GBP', 125.0000, N'GBP');

INSERT  INTO [raw_google].[vw_PriceInsights] (
    [partition_date],
    [aggregator_id],
    [merchant_id],
    [id],
    [title],
    [brand],
    [offer_id],
    [price_value],
    [price_currency],
    [suggested_price_value],
    [suggested_price_currency]
)
VALUES                                      ('2026-01-15', 1, 131845897, N'TEST-PROD-1', N'Synthetic product', N'Test Brand', N'TEST-PROD-1', 120.0000, N'GBP', 118.0000, N'GBP');

-- Verify each Google raw table contains exactly one fixture record before commit.
IF (SELECT COUNT(*)
    FROM   [raw_google].[ads_AccountBasicStats_5605924582]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[ads_AccountConversionStats_5605924582]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[ads_AccountStats_5605924582]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[ads_AssetGroup_5605924582]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[ads_BudgetStats_5605924582]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[ads_CampaignConversionStats_5605924582]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[ads_CampaignLabel_5605924582]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[ads_CampaignStats_5605924582]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[LocalInventories_131845897]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[PriceCompetitiveness_131845897]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[PriceInsights_131845897]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[vw_daily_product_performance]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[vw_PriceCompetitiveness]) <> 1
   OR (SELECT COUNT(*)
       FROM   [raw_google].[vw_PriceInsights]) <> 1
    BEGIN
        THROW 52182, 'Google seed failed: fixture row counts do not match the one-row contract.', 1;
    END

COMMIT TRANSACTION;

PRINT 'Synthetic Google fixture seeded successfully.';