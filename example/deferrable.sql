drop table if exists t_example_deferrable;

create table t_example_deferrable
(
  id integer not null,
  nn integer,
  time_create timestamp not null default localtimestamp,
  constraint t_example_deferrable_pk primary key ( id ),
  constraint t_example_deferrable_uq unique (nn)
);

select
  connamespace::regnamespace schema,
  conrelid::regclass table, conname, contype type,
  condeferrable deferrable, condeferred deferred
from pg_constraint where contype in ('p', 'u')
  and connamespace::regnamespace::text != 'pg_catalog'
  and conname='t_example_deferrable_uq';

insert into t_example_deferrable(id, nn, time_create)
  with a as
    ( select 
        n,
        cast((random() * 20000) as integer) as nn,
        random_time() time_create -- create in example_partition.sql
  		from generate_series(1, 100000) n )
  select * from a on conflict (nn) do nothing;


alter table t_example_deferrable alter constraint t_example_deferrable_uq deferrable;

--alter table t_example_deferrable drop constraint t_example_deferrable_uq, add constraint t_example_deferrable_uq unique (nn) deferrable initially deferred;
alter table t_example_deferrable drop constraint t_example_deferrable_uq, add constraint t_example_deferrable_uq unique (nn) deferrable;

select
  connamespace::regnamespace schema,
  conrelid::regclass table, conname, contype type,
  condeferrable deferrable, condeferred deferred
from pg_constraint where contype in ('p', 'u')
  and connamespace::regnamespace::text != 'pg_catalog'
  and conname='t_example_deferrable_uq';

set statement_timeout to '120s';
/*
begin isolation level read committed;
with
  nn as (
    select
      id,
      row_number() over () n
    from t_example_deferrable
    )
update t_example_deferrable ed set nn = nn.n
  from nn
  where ed.id = nn.id;
commit;
*/

start transaction deferrable;
with
  nn as (
    select
      id,
      row_number() over () n
    from t_example_deferrable
    )
update t_example_deferrable ed set nn = nn.n
  from nn
  where ed.id = nn.id;
commit;
