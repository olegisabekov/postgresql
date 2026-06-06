drop table if exists t_example_new_prod;
drop table if exists t_example_prod;
drop table if exists t_example_type_p;

create table t_example_type_p
(
  id int8 not null,
  name varchar(20) not null,
  constraint t_example_type_p_pk primary key ( id )
);

insert into t_example_type_p values(0, 'trash');
insert into t_example_type_p values(1, 'active');
insert into t_example_type_p values(2, 'signed');

create table t_example_prod
(
  id integer not null,
  idp int8 not null,
  day_create timestamp not null default localtimestamp,
  operday date not null,
  suma money not null,
  constraint t_example_prod_pk primary key ( id ),
  constraint t_example_prod_fk foreign key ( idp ) references t_example_type_p (id)
);

create index t_example_prod_inx_od ON t_example_prod (operday);

insert into t_example_prod(id, idp, day_create, operday, suma)
with a as ( select n as n, random_time() time_create
  						from generate_series(1, 100000) n )
select 
	n,
  0,
  time_create,
	date_trunc('day', time_create),
  cast((random() * 100) as numeric(16,2))
from a;

create table t_example_new_prod
(
  id integer not null,
  time_create timestamp,
  constraint t_example_new_prod_pk primary key ( id )
);

insert into t_example_new_prod(id, time_create)
  with a as
    ( select 
        cast((random() * 200000) as integer) as id,
        random_time() time_create -- create in example_partition.sql
  		from generate_series(1, 100000) n )
  select * from a on conflict (id) do nothing;
  
merge into t_example_prod as p
  using t_example_new_prod as a on p.id = a.id
    when matched and p.idp = 0 then
      update set idp = 1
    when not matched then
      insert(id, idp, day_create, operday, suma) 
        values(	a.id,
                0,
                a.time_create,
                date_trunc('day', a.time_create),
                cast((random() * 100) as numeric(16,2)));
