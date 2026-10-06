CREATE VIEW -- OR ALTER
[marts].[vw_dim_customer]
AS
SELECT -- models/4_dimensions/dim_customer.sql
       -- store (customers) fields first
       customer_code,
       dbo.fn_TitleCase(customer_name) AS customer_name,
       customer_type,
       CAST (price_band AS INT) AS price_band,
       company_name AS company,
       is_on_stop,
       CAST (is_archived AS BIT) AS is_archived,
       CAST (gender AS BIT) AS is_confirmed_female,
       credit_terms,
       credit_limit,
       credit_balance,
       account_opened_date,
       ISNULL(row_modified_datetime, '1900-01-01') AS row_modified_datetime, -- NULL would never clear the loader's incremental watermark filter
       ISNULL(last_in_store_date, account_opened_date) AS last_in_store_date,
       -- unique email (valid only, de-duped by newest last_modified_date; others become NULL)
       email,
       -- web fields next
       web_customer_id,
       web_cp_connection,
       web_first_name,
       web_last_name,
       web_company,
       web_phone,
       web_address_line_1,
       web_address_line_2,
       web_postal_code,
       web_state_code,
       web_state,
       web_city,
       web_country_code,
       web_customer_type,
       web_created_at,
       -- Classification columns (sourced from int.consolidated_customers)
       retail_trade
FROM   int.[consolidated_customers];