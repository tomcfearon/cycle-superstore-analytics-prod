:ON ERROR EXIT

-- Keep pull-request assertions deterministic and limited to foundational warehouse contracts.
:r data_platform/tests/assertions/invariants/dim_customer_not_null_customer_code.sql
:r data_platform/tests/assertions/invariants/dim_customer_unique_customer_code.sql
:r data_platform/tests/assertions/invariants/dim_employee_not_null_employee_key.sql
:r data_platform/tests/assertions/invariants/dim_employee_unique_employee_key.sql
:r data_platform/tests/assertions/invariants/dim_product_not_null_product_key.sql
:r data_platform/tests/assertions/invariants/dim_product_unique_product_key.sql
:r data_platform/tests/assertions/invariants/fct_order_invoices_unique_transaction_line.sql
:r data_platform/tests/assertions/invariants/fct_service_invoices_unique_transaction_line.sql
:r data_platform/tests/assertions/invariants/fct_order_credits_service_credits_mutually_exclusive.sql
:r data_platform/tests/assertions/contracts/order_invoice_fixture_assertions.sql
:r data_platform/tests/assertions/contracts/service_invoice_fixture_assertions.sql

PRINT 'PASS: core warehouse database assertions.';