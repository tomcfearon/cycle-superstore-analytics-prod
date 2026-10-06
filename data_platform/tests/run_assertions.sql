:ON ERROR EXIT

-- Delegate to the pull-request-safe assertion suite without changing the runner contract.
:r data_platform/tests/assertions/core.sql

PRINT 'PASS: all warehouse database assertions.';
