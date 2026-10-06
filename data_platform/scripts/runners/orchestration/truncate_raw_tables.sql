-- Truncate all raw source tables before ADF reload
-- Excludes: raw_inventory.Inventory, raw_ccdata.CategoryMap, raw_365.*, raw_google.*
EXEC [dbo].[usp_truncate_raw_tables];
