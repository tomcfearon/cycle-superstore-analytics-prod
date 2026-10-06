SELECT name,
       desired_state_desc,
       actual_state_desc,
       reason_desc
FROM   sys.database_automatic_tuning_options
WHERE  name = 'FORCE_LAST_GOOD_PLAN';