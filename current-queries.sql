--
-- Currently running queries
--
SELECT
    pid,
    age(query_start, clock_timestamp()),
    usename,
    LEFT (query, 8000),
    state 
FROM pg_stat_activity 
WHERE query != '<IDLE>' 
AND query NOT ILIKE'%pg_stat_activity%' 
AND state = 'active' 
ORDER BY query_start DESC;
  
-- -- Cancel by PID
-- SELECT pg_cancel_backend(____);
