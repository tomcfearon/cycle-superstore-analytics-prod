CREATE
-- OR ALTER
VIEW [dbo].[46 - Order Time] AS

/*
    Time dimension — one row per second of the day (86,400 rows).
    Converted from the "46 - Time" DAX calculated table.

    Store hours logic:
      Open  : 09:00 (32400s) – 20:15 (72900s)
      Block 1 (irregular): 09:00–10:15
      Subsequent blocks  : 10:15–11:15, 11:15–12:15 … up to 20:15
      Outside open hours : "Closed Hours"
*/

WITH

/* -----------------------------------------------------------------------
   1. Generate 0–86399  (n4 = 65,536 rows, filter to 86,400)
   ----------------------------------------------------------------------- */
n0 AS (SELECT 1 AS n UNION ALL SELECT 1),
n1 AS (SELECT a.n FROM n0 a CROSS JOIN n0 b),     --       4
n2 AS (SELECT a.n FROM n1 a CROSS JOIN n1 b),     --      16
n3 AS (SELECT a.n FROM n2 a CROSS JOIN n2 b),     --     256
n4 AS (SELECT a.n FROM n3 a CROSS JOIN n3 b),     --  65,536
n5 AS (SELECT a.n FROM n4 a CROSS JOIN n0 b),     -- 131,072  (> 86,400)
nums AS (
    SELECT seq FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS seq
        FROM   n5
    ) x
    WHERE seq < 86400
),

/* -----------------------------------------------------------------------
   2. Decompose each second into H/M/S parts
   ----------------------------------------------------------------------- */
parts AS (
    SELECT
        seq,
        seq / 3600             AS hr,
        (seq % 3600) / 60      AS mn,
        seq % 60               AS ss
    FROM nums
),

/* -----------------------------------------------------------------------
   3. Store Hours block boundaries
      Constants (seconds from midnight):
        open_s      = 32400   (09:00)
        first_end_s = 36900   (10:15)  — end of irregular first block
        close_s     = 72900   (20:15)
   ----------------------------------------------------------------------- */
blocks AS (
    SELECT
        seq, hr, mn, ss,

        -- Block start (seconds): reused for both label and sort key
        CASE
            WHEN seq < 32400 OR seq >= 72900 THEN 999999    -- closed
            WHEN seq < 36900                 THEN 32400     -- first block 09:00
            ELSE 36900 + ((seq - 36900) / 3600) * 3600      -- hourly blocks from 10:15
        END AS block_start_s,

        -- Block end (seconds): used for label only
        CASE
            WHEN seq < 32400 OR seq >= 72900 THEN 999999    -- closed
            WHEN seq < 36900                 THEN 36900     -- first block ends 10:15
            ELSE
                CASE
                    WHEN 36900 + ((seq - 36900) / 3600 + 1) * 3600 < 72900
                        THEN 36900 + ((seq - 36900) / 3600 + 1) * 3600
                    ELSE 72900
                END
        END AS block_end_s

    FROM parts
)

SELECT
    seq                                                                         AS [Second Of Day],
    hr                                                                          AS [Hour Number],
    mn                                                                          AS [Minute Of Hour],
    ss                                                                          AS [Second Of Minute],

    -- Return a proper TIME value; format as HH:mm:ss in the Power BI model
    TIMEFROMPARTS(hr, mn, ss, 0, 0)                                            AS [Time],

    RIGHT('0' + CAST(hr AS varchar(2)), 2) + ':00'                             AS [Hour],

    -- Store Hours Category label  e.g. "09:00–10:15" or "Closed Hours"
    CASE
        WHEN seq < 32400 OR seq >= 72900
            THEN 'Closed Hours'
        ELSE
            RIGHT('0' + CAST(block_start_s / 3600        AS varchar(2)), 2) + ':'
          + RIGHT('0' + CAST((block_start_s % 3600) / 60 AS varchar(2)), 2)
          + N'–'   -- en dash, matching original DAX
          + RIGHT('0' + CAST(block_end_s / 3600          AS varchar(2)), 2) + ':'
          + RIGHT('0' + CAST((block_end_s % 3600) / 60   AS varchar(2)), 2)
    END                                                                         AS [Store Hours Category],

    -- Sort key: block start in seconds; 999999 sorts Closed Hours to the bottom
    CASE
        WHEN seq < 32400 OR seq >= 72900 THEN 999999
        ELSE block_start_s
    END                                                                         AS [Store Hours Sort]

FROM blocks;
