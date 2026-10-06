-- Source: BigQuery Data Transfer Service - Google Merchant Center (Local Inventories report).
-- Purpose: Local store-level offer state including price, sale windows, availability, quantity, pickup method/SLA, and in-store location.
-- Reference: https://docs.cloud.google.com/bigquery/docs/merchant-center-local-inventories-schema
CREATE
-- OR ALTER
VIEW [stg].[google_local_inventories] AS
SELECT
        t.[_DATA_DATE],
        t.[product_id],
        t.[merchant_id],
        t.[aggregator_id],
        t.[store_code],
        t.[price],
        t.[sale_price],
        t.[sale_price_effective_start_date],
        t.[sale_price_effective_end_date],
        t.[availability],
        t.[quantity],
        t.[pickup_method],
        t.[pickup_sla],
        t.[instore_product_location]
    FROM
        [raw_google].[LocalInventories_131845897] AS t
