-- Execute modular fixtures in the dependency order required by raw-source relationships.
:r data_platform/tests/seeds/seed_customer.sql
:r data_platform/tests/seeds/seed_employee.sql
:r data_platform/tests/seeds/seed_product.sql
:r data_platform/tests/seeds/seed_inventory.sql
:r data_platform/tests/seeds/seed_purchasing.sql
:r data_platform/tests/seeds/seed_sales.sql
:r data_platform/tests/seeds/seed_service.sql
:r data_platform/tests/seeds/seed_google.sql