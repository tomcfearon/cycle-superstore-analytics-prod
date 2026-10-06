CREATE FUNCTION dbo.fn_TitleCase (@input varchar(4000))
RETURNS varchar(4000)
AS
BEGIN
    DECLARE @output varchar(4000) = LOWER(LTRIM(RTRIM(@input)));
    DECLARE @i int = 1;

    -- Capitalize first character
    SET @output = STUFF(@output, 1, 1, UPPER(SUBSTRING(@output, 1, 1)));

    -- Capitalize after spaces, hyphens, slashes
    WHILE @i <= LEN(@output)
    BEGIN
        IF SUBSTRING(@output, @i, 1) IN (' ', '-', '/')
        BEGIN
            SET @output =
                STUFF(
                    @output,
                    @i + 1,
                    1,
                    UPPER(SUBSTRING(@output, @i + 1, 1))
                );
        END
        SET @i += 1;
    END

    RETURN @output;
END;
