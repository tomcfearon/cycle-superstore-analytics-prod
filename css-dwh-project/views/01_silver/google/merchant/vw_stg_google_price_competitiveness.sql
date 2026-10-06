-- Source: BigQuery Data Transfer Service - Google Merchant Center (Price Competitiveness report).
-- Purpose: Daily per-product, per-country benchmark pricing versus market peers to assess pricing competitiveness.
-- Reference: https://docs.cloud.google.com/bigquery/docs/merchant-center-price-competitiveness-schema
CREATE
-- OR ALTER
VIEW [stg].[google_price_competitiveness] AS
SELECT
        t.[partition_date],
        t.[aggregator_id],
        t.[merchant_id],
        t.[id],
        t.[title],
        t.[brand],
        t.[offer_id] as product_key,
        t.[report_country_code],
        t.[product_type_l1],
        t.[product_type_l2],
        t.[product_type_l3],
        t.[product_type_l4],
        t.[product_type_l5],
        t.[category_l1],
        t.[category_l2],
        t.[category_l3],
        t.[category_l4],
        t.[category_l5],
        -- price fields: BigQuery view pre-converts from micro-units — values are already in EUR
        t.[price_value]           AS [price],
        t.[benchmark_price_value] AS [benchmark_price]
    FROM
        [raw_google].[vw_PriceCompetitiveness] AS t  -- ADF pipeline target; BigQuery view flattens price STRUCTs
