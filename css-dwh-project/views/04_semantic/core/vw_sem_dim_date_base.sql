CREATE
-- OR ALTER
VIEW [dbo].[vw_dim_date_base] AS

/*
    Core date dimension — single source of truth.

    Both role-playing date views SELECT * from this view:
        [41 - Document Date]  →  SELECT * FROM [dbo].[vw_dim_date_base]
        [49 - Order Date]     →  SELECT * FROM [dbo].[vw_dim_date_base]

    Completion flags use a shop-close threshold (shop_close_utc below).
    If the ERP refresh occurred after that UTC time, the refresh date itself
    counts as a completed day.  If the refresh occurred before that time,
    only dates strictly before the refresh date are considered complete.

    Week calculations use Monday as the first day (ISO-style),
    DATEFIRST-independent via the 1900-01-01 anchor.
*/

WITH

/* -----------------------------------------------------------------------
   Shop-close threshold (UTC).
   4 PM UTC = effective end of trading day for completion flag purposes.
   Update this value here if the shop's close time changes.
   ----------------------------------------------------------------------- */
shop_params AS (
    SELECT CAST('16:00:00' AS time) AS shop_close_utc
),

/* -----------------------------------------------------------------------
    1. Pull the effective CCData refresh datetime.
        Source-side raw_ccdata can land before the warehouse facts finish
        loading, so freshness flags use the minimum of source and warehouse
        fact refresh times.
    ----------------------------------------------------------------------- */
last_refresh AS (
     SELECT effective_last_refresh_utc AS last_refresh_utc
     FROM   [dbo].[vw_ccdata_effective_refresh]
),

/* -----------------------------------------------------------------------
   2. Derive calendar boundaries and the last completed date.

      last_completed_date: the latest date whose data can be considered
      fully captured.
        • Refresh after shop_close_utc → the refresh date is complete.
        • Refresh before shop_close_utc → only yesterday is complete.
   ----------------------------------------------------------------------- */
params AS (
    SELECT
        CAST('20100101' AS date)                                        AS start_date,
        -- Calendar extends to end of the year in which the last refresh occurred
        DATEFROMPARTS(YEAR(CAST(r.last_refresh_utc AS date)), 12, 31)  AS end_date,
        -- Last day whose data is fully captured, per shop-close rule
        CAST(
            CASE
                WHEN CAST(r.last_refresh_utc AS time) >= s.shop_close_utc
                THEN CAST(r.last_refresh_utc AS date)
                ELSE DATEADD(DAY, -1, CAST(r.last_refresh_utc AS date))
            END
        AS date)                                                        AS last_completed_date
    FROM  last_refresh r
    CROSS JOIN shop_params s
),

/* -----------------------------------------------------------------------
   3. Generate a row sequence large enough to span start → end.
      n4 = 65,536 rows — sufficient for > 170 years.
   ----------------------------------------------------------------------- */
n0 AS (SELECT 1 AS n UNION ALL SELECT 1),
n1 AS (SELECT a.n FROM n0 a CROSS JOIN n0 b),      --       4
n2 AS (SELECT a.n FROM n1 a CROSS JOIN n1 b),      --      16
n3 AS (SELECT a.n FROM n2 a CROSS JOIN n2 b),      --     256
n4 AS (SELECT a.n FROM n3 a CROSS JOIN n3 b),      --  65,536
nums AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS seq
    FROM   n4
),

/* -----------------------------------------------------------------------
   4. Expand to one row per calendar date
   ----------------------------------------------------------------------- */
date_series AS (
    SELECT
        DATEADD(DAY, nums.seq, params.start_date) AS [Date],
        params.last_completed_date
    FROM   nums
    CROSS JOIN params
    WHERE  DATEADD(DAY, nums.seq, params.start_date) <= params.end_date
),

/* -----------------------------------------------------------------------
   5. Pre-compute frequently reused date parts.
      dow0: DATEFIRST-independent day-of-week  0=Mon … 6=Sun
            (1900-01-01 is a Monday, so modulo-7 offset is stable)
   ----------------------------------------------------------------------- */
date_calc AS (
    SELECT
        [Date],
        last_completed_date,
        YEAR ([Date])                                                   AS yr,
        MONTH([Date])                                                   AS mo,
        DAY  ([Date])                                                   AS dy,
        DATEPART(QUARTER, [Date])                                       AS qtr,
        DATEDIFF(DAY, '19000101', [Date]) % 7                          AS dow0,
        DATEFROMPARTS(YEAR([Date]), 1, 1)                              AS jan1,
        DATEDIFF(DAY, '19000101', DATEFROMPARTS(YEAR([Date]), 1, 1)) % 7
                                                                        AS jan1_dow0
    FROM date_series
),

/* -----------------------------------------------------------------------
   6. Derive week anchors
   ----------------------------------------------------------------------- */
week_calc AS (
    SELECT
        *,
        -- Monday on or before Jan 1 of the year (week-1 anchor)
        DATEADD(DAY, -jan1_dow0, jan1)                                 AS week1_monday,
        -- Monday of the current date's week
        DATEADD(DAY, -dow0, [Date])                                    AS current_week_monday,
        -- Monday of the model's current week, based on last_completed_date
        DATEADD(DAY, -(DATEDIFF(DAY, '19000101', last_completed_date) % 7), last_completed_date)
                                                                        AS last_completed_week_monday
    FROM date_calc
),

/* -----------------------------------------------------------------------
   7. Compute week numbers (WEEKNUM type-2 equivalent: week 1 contains Jan 1,
      weeks start Monday)
   ----------------------------------------------------------------------- */
week_nums AS (
    SELECT
        *,
        DATEDIFF(DAY, week1_monday, [Date]) / 7 + 1                    AS week_num
    FROM week_calc
)

/* -----------------------------------------------------------------------
   8. Final SELECT
   ----------------------------------------------------------------------- */
SELECT
    /* ---- Date ---- */
    [Date]                                                              AS [Date],
    DATEDIFF(DAY, '20100101', [Date]) + 1                              AS [Date Number],

    /* ---- Year ---- */
    yr                                                                  AS [Year],

    /* ---- Quarter ---- */
    qtr                                                                 AS [Quarter Number],
    'Q' + CAST(qtr AS varchar(1))                                      AS [Quarter],
    DATEDIFF(
        DAY,
        DATEFROMPARTS(yr, (qtr - 1) * 3 + 1, 1),
        [Date]
    ) + 1                                                               AS [Day of Quarter Number],
    yr * 4 + qtr - 1                                                   AS [Year Quarter Number],
    'Q' + CAST(qtr AS varchar(1)) + '-' + CAST(yr AS char(4))         AS [Year Quarter],

    /* ---- Week ---- */
    week_num                                                            AS [Week Number],
    'W' + RIGHT('0' + CAST(week_num AS varchar(2)), 2)                AS [Week],
    yr * 53 + week_num - 1                                             AS [Year Week Number],
    CAST(yr AS char(4)) + ' - W' + RIGHT('0' + CAST(week_num AS varchar(2)), 2)
                                                                        AS [Year Week],

    /* ---- Month ---- */
    mo                                                                  AS [Month Number],
    LEFT(DATENAME(MONTH, [Date]), 3)                                   AS [Month],
    dy                                                                  AS [Day of Month Number],
    yr * 12 + mo - 1                                                   AS [Year Month Number],
    LEFT(DATENAME(MONTH, [Date]), 3) + ' ' + CAST(yr AS char(4))      AS [Year Month],
    CAST(DATEFROMPARTS(yr, mo, 1) AS date)                             AS [Start of Month],
    CAST(EOMONTH([Date]) AS date)                                      AS [End of Month],
    mo - 3 * (qtr - 1)                                                 AS [Month In Quarter Number],

    /* ---- Day ---- */
    dow0 + 1                                                            AS [Day Of Week Number],   -- 1=Mon, 7=Sun
    DATEDIFF(DAY, jan1, [Date]) + 1                                    AS [Day Of Year Number],
    CASE dow0
        WHEN 0 THEN 'Mon'
        WHEN 1 THEN 'Tue'
        WHEN 2 THEN 'Wed'
        WHEN 3 THEN 'Thu'
        WHEN 4 THEN 'Fri'
        WHEN 5 THEN 'Sat'
        WHEN 6 THEN 'Sun'
    END                                                                 AS [Day of Week],

    -- Day number within the week (1 = first calendar day of that week).
    -- Week 1 is anchored on Jan 1 itself, not the Monday before it.
    DATEDIFF(
        DAY,
        CASE WHEN week_num = 1 THEN jan1 ELSE current_week_monday END,
        [Date]
    ) + 1                                                               AS [Weekday Number],

    /* ---- Flags ---- */
    CAST(CASE WHEN dow0 < 5 THEN 1 ELSE 0 END AS bit)                 AS [Is Working Day],

    CASE
        WHEN mo IN (1, 2, 9, 10, 11, 12) THEN 'Irish Winter'
        ELSE 'Irish Summer'
    END                                                                 AS [Irish Seasons],

    /* ---- Completed period flags (driven by last_completed_date) ---- */
    -- A day is complete when the shop-close-adjusted last_completed_date >= that date.
    CAST(CASE WHEN [Date] <= last_completed_date THEN 1 ELSE 0 END AS bit)
                                                                        AS [Is Completed Day],

    -- Week is complete when last_completed_date has passed the Sunday of that week.
    CAST(CASE
        WHEN last_completed_date >= DATEADD(DAY, 6 - dow0, [Date]) THEN 1
        ELSE 0
    END AS bit)                                                         AS [Is Completed Week],

    -- Is Current Week is the Monday-start week containing the model's last_completed_date.
    CAST(CASE
        WHEN current_week_monday = last_completed_week_monday THEN 1
        ELSE 0
    END AS bit)                                                         AS [Is Current Week],

    CAST(CASE
        WHEN last_completed_date >= CAST(EOMONTH([Date]) AS date) THEN 1
        ELSE 0
    END AS bit)                                                         AS [Is Completed Month],

    -- Quarter end = last day of the third month of the quarter
    CAST(CASE
        WHEN last_completed_date >= CAST(EOMONTH([Date], 3 - (mo - 3 * (qtr - 1))) AS date) THEN 1
        ELSE 0
    END AS bit)                                                         AS [Is Completed Quarter],

    CAST(CASE
        WHEN last_completed_date >= DATEFROMPARTS(yr, 12, 31) THEN 1
        ELSE 0
    END AS bit)                                                         AS [Is Completed Year]

FROM week_nums;
