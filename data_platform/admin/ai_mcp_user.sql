-- 1. Create the user with a strong password
ALTER USER [ai_copilot_readonly] --dev only
    WITH PASSWORD = '<strong_password_here_key_vault>';

-- 2. Add the user to the read-only role
ALTER ROLE db_datareader ADD MEMBER [ai_copilot_readonly];