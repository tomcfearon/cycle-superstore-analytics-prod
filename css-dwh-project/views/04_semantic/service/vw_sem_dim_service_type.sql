CREATE
-- OR ALTER
VIEW [dbo].[50 - Service Type] AS

/*
    Static service type dimension — inlined as VALUES rather than sourced from a
    physical table, because the category list is small and stable.  No loader or
    DACPAC seed script needed; update the VALUES list here if categories change.
*/

SELECT [Service Type Key], [Service Category], [Sort Order]
FROM (VALUES
--   key   category             sort
    ( 1,  'Brand Bike',        1),
    ( 2,  'Customer Bike',     2),
    ( 3,  'Fork',              3),
    ( 4,  'No Data',           6),
    ( 5,  'Pedal',             5),
    ( 6,  'Wheel',             4)
) AS t ([Service Type Key], [Service Category], [Sort Order]);
