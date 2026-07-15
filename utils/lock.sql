\pset format wrapped
-- dnf install postgresql18-contrib.x86_64
create extension pageinspect;

select '(0,'||lp||')' as ctid,
       t_xmax as xmax,
       case when (t_infomask & 128) > 0   then 't' end as lock_only,
       case when (t_infomask & 4096) > 0  then 't' end as is_multi,
       case when (t_infomask2 & 8192) > 0 then 't' end as keys_upd,
       case when (t_infomask & 16) > 0 then 't' end as keyshr_lock,
       case when (t_infomask & 16+64) = 16+64 then 't' end as shr_lock
from heap_page_items(get_raw_page('accounts',0))
order by lp;


create extension pgrowlocks;

select * from pgrowlocks('accounts') \gx

select pid,
       locktype,
       case locktype
         when 'relation' then relation::regclass::text
         when 'transactionid' then transactionid::text
         when 'tuple' then relation::regclass::text||':'||tuple::text
       end as lockid,
       mode,
       granted
from pg_locks
where locktype in ('relation','transactionid','tuple')
and (locktype != 'relation' or relation = 'accounts'::regclass);

-- номер блокирующего процесса
-- select pg_blocking_pids(xxxx);
-- select * from pg_stat_activity where pid = any(pg_blocking_pids(4782)) \gx
