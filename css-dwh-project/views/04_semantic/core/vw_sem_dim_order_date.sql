CREATE
-- OR ALTER
VIEW [dbo].[49 - Order Date] AS

/*
    Role-playing date dimension -- Order Date.
    All logic lives in [dbo].[vw_dim_date_base]; this view is a thin wrapper
    so Power BI can relate fact tables on order date independently from document date.
    See vw_sem_dim_date_base.sql to change date logic or the shop-close threshold.
*/

SELECT * FROM [dbo].[vw_dim_date_base];
