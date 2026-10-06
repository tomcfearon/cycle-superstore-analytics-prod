
CREATE USER [df-css-ana-dev-neu] FROM EXTERNAL PROVIDER;

GRANT INSERT on SCHEMA::raw_ccdata   TO [df-css-ana-dev-neu];
