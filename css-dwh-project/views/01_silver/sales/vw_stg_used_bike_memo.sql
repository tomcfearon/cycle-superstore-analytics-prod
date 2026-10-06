CREATE
-- OR ALTER
VIEW [stg].[used_bike_memo] AS
SELECT ub.UsedBikeID AS used_bike_id,
    CAST(ub.TradeInDate AS DATE) AS memo_date,
    NULLIF(ub.CustomerCode, '') AS customer_code,
    ub.[Description] AS [description],
    ub.ModelNo AS model_no,
    ub.Make AS brand,
    NULLIF(ub.Make, '') AS make,
    ub.Colour AS colour,
    ub.Size AS size,
    ub.RetailPrice AS retail_price,
    ub.CostPrice AS cost_price,
    ub.SellPrice AS sale_price,
    ub.SiteNo AS site_no,
    ub.StockLocation AS stock_location,
    ub.Salesperson_1ID AS salesperson1_key,
    ub.Salesperson_2ID AS salesperson2_key,
    ub.RepairsRequired AS repairs_required,
    ub.PartsSoNo AS parts_so_no,
    NULLIF(ub.InStoreMemo, '') AS in_store_memo,
    ISNULL(CAST(ub.BikeSold_Date AS DATE), CAST(ub.TradeInDate AS DATE)) AS sold_date,
    ub.BikeSold_Date AS bike_sold_date,
    ub.BikeSold_CustomerCode AS sold_customer_code,
    ub.BikeSold_Price AS sold_price,
    ub.BikeSold_Payment AS sold_payment_amount,
    ub.BikeSold_SalespersonID AS sold_salesperson_key,
    ub.TillSalespersonID AS till_salesperson_id,
    ub.CustomerItem AS customer_item,
    ub.FrameNo AS frame_no,
    ub.FaultNo AS service_order_number,
    NULLIF(ub.FaultNo, '') AS fault_no,
    ub.RepairCostPrice AS service_cost_price,
    CASE ub.[Status]
        WHEN 'Pending' THEN 'Pending'
        WHEN 'Ready for sale' THEN 'Ready For Sale'
        WHEN 'Sold' THEN 'Sold'
        WHEN 'Scrap' THEN 'Scrap'
        WHEN 'Ret to seller' THEN 'Return To Seller'
        END AS used_bike_status,
    ub.[Status] AS [status],
    NULLIF(ub.Category, '') AS used_bike_category,
    ub.Category AS category,
    CASE ub.Web_Status
        WHEN '' THEN 'Unknown'
        WHEN 'active' THEN 'Active'
        WHEN 'pending' THEN 'Pending'
        WHEN 'sold' THEN 'Sold'
        ELSE ub.Web_Status
        END AS web_status,
    ub.Web_Status AS web_status_raw,
    NULLIF(ub.Web_BikeId, 0) AS web_bike_id,
    ub.Web_BikeId AS web_bike_id_raw
FROM [raw_ccdata].[UsedBikes] AS ub;