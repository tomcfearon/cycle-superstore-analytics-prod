CREATE
-- OR ALTER
VIEW [dbo].[41 - Document Date] AS

/*
    Role-playing date dimension -- Document Date (Invoice/Transaction Date).
    All logic lives in [dbo].[vw_dim_date_base]; this view is a thin wrapper
    so Power BI can relate fact tables on document date independently.
    See vw_sem_dim_date_base.sql to change date logic or the shop-close threshold.
*/

SELECT * FROM [dbo].[vw_dim_date_base];
