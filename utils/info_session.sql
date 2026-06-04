select * from pg_stat_activity;

select
  count(1),
  datname,
  state
from  pg_stat_activity
group by datname, state
order by 1 desc;

select
  count(1),
  state,
  wait_event_type,
  wait_event
from pg_stat_activity
group by state, wait_event_type, wait_event
order by 1 desc;

select
  count(1) as total_connections,
  current_setting('max_connections')::int as max_connections,
  round(count(1)::numeric / current_setting('max_connections')::int * 100, 1) as pct_used
from
    pg_stat_activity;


