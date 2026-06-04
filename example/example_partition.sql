create table t_example_part
(
  id integer not null,
  time_create timestamp not null default localtimestamp,
  date_create date not null default date_trunc('day', now()),
  text varchar(30),
  constraint t_example_part_pk primary key (id, date_create)
) partition by range (date_create);

create table t_example_part_y2026m05 partition of t_example_part
    for values from ('2026-05-01') to ('2026-06-01');

create table t_example_part_y2026m06 partition of t_example_part
    for values from ('2026-06-01') to ('2026-07-01');


create function random_time() returns timestamp as $$
  select '2026-05-01 00:00:00'::timestamp  + ('2026-06-30 23:59:59'::timestamp - '2026-05-01 00:00:00'::timestamp) * random()
$$ language sql;

insert into t_example_part(id, time_create, date_create, text)
with a as ( select n as n 
  						from generate_series(1, 200000) n ),
  	 b as ( select 
							n,
							random_time() time_create
							from a )
select n,
  time_create,
	date_trunc('day', time_create),
	random_string(20) as text -- create in example err_to_number
from b;

explain ( analyze true, buffers true )
select * from t_example_part
  where date_create = '2026-06-01';

create index t_example_part_inx_dc ON t_example_part (date_create);

create index concurrently t_example_part_y2026m06_t on t_example_part_y2026m06 (text);

select * from t_example_part_y2026m06;

with lst as (
    select c.oid,nspname as table_schema, relname as table_name
              , c.reltuples as row_estimate
              , pg_total_relation_size(c.oid) as total_bytes
              , pg_indexes_size(c.oid) as index_bytes
              , pg_total_relation_size(reltoastrelid) as toast_bytes
          from pg_class c
          left join pg_namespace n on n.oid = c.relnamespace
          where relkind = 'r' ),
    t as ( select *, total_bytes-index_bytes-coalesce(toast_bytes,0) as table_bytes from lst )        
select *, 
	pg_size_pretty(total_bytes) as total,
  pg_size_pretty(index_bytes) as index,
  pg_size_pretty(toast_bytes) as toast,
  pg_size_pretty(table_bytes) as table
  from t
	where table_name like 't_example%part%';
	
drop table t_example_part;
