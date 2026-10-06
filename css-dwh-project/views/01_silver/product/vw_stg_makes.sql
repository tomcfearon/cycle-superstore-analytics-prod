CREATE
-- OR ALTER
VIEW [stg].[makes] AS
SELECT
    LTRIM(RTRIM(m.[Make])) AS make,
    m.[WebAddress] AS web_address,
    m.[Target Markup Main RRP] AS target_markup_main_rrp,
    m.[Target Markup Sun RRP] AS target_markup_sun_rrp,
    CAST(ISNULL(m.[Distribution], 0) AS BIT) AS is_distribution,
    CAST(ISNULL(m.[Active], 0) AS BIT) AS is_active,
    NULLIF(m.[Notes], '') AS notes,
    m.[WinterForwardOrderDate] AS winter_forward_order_date,
    m.[SummerForwardOrderDate] AS summer_forward_order_date,
    m.[LastPurchasedDate] AS last_purchased_date,
    m.[LastReviewDate] AS last_review_date,
    m.[NextReviewDate] AS next_review_date,
    m.[SupplierName] AS supplier_name,
    CAST(ISNULL(m.[BonusVoucherExclude], 0) AS BIT) AS bonus_voucher_exclude,
    m.[TargetMarginMain] AS target_margin_main,
    m.[TargetMarginSundry] AS target_margin_sundry
FROM [raw_ccdata].[Makes] AS m;