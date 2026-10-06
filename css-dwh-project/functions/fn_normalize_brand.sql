CREATE FUNCTION dbo.fn_NormalizeBrand (@brand NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    RETURN CASE
            WHEN @brand = 'Gt'
                THEN 'GT Bikes'
            WHEN @brand = 'GT'
                THEN 'GT Bikes'
            WHEN @brand = 'BL'
                THEN 'Bicycle-Line'
            WHEN @brand = 'Bicycle-line'
                THEN 'Bicycle-Line'
            WHEN @brand = 'Seal Skinz'
                THEN 'Sealskinz'
            WHEN @brand = 'Profile'
                THEN 'Profile Design'
            WHEN @brand = 'Park Tools'
                THEN 'Park Tool'
            WHEN @brand = 'Aqua Sphere'
                THEN 'Aquasphere'
            ELSE @brand
            END;
END;