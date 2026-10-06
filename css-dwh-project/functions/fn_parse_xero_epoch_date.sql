CREATE FUNCTION dbo.fn_ParseXeroEpochDate (@epoch_string NVARCHAR(50))
RETURNS DATETIME2
AS
BEGIN
    DECLARE @digit_len INT;
    DECLARE @ms BIGINT;

    IF @epoch_string IS NULL OR PATINDEX('/Date(%', @epoch_string) <> 1
        RETURN NULL;

    -- digits run immediately after "/Date(" (position 7); stop at "+" or ")" for the optional timezone offset
    SET @digit_len = PATINDEX('%[^0-9]%', SUBSTRING(@epoch_string, 7, 20)) - 1;
    IF @digit_len <= 0
        SET @digit_len = LEN(@epoch_string) - 6;

    SET @ms = TRY_CAST(SUBSTRING(@epoch_string, 7, @digit_len) AS BIGINT);
    IF @ms IS NULL
        RETURN NULL;

    -- split into whole days + remainder ms to avoid INT overflow in DATEADD(MILLISECOND, ...)
    RETURN DATEADD(MILLISECOND, @ms % 86400000, DATEADD(DAY, @ms / 86400000, CAST('1970-01-01' AS DATETIME2)));
END;
