drop table if exists t_example_cw;
drop table if exists t_example_type_cw;

create table t_example_type_cw
(
  id int8 not null,
  name varchar(20) not null,
  constraint t_example_type_cw_pk primary key ( id )
);

insert into t_example_type_cw values(0, 'trash');
insert into t_example_type_cw values(1, 'one');
insert into t_example_type_cw values(2, 'two');
insert into t_example_type_cw values(3, 'three');

create table t_example_cw
(
  id integer not null,
  idt int8 not null,
  day_create timestamp not null default localtimestamp,
  constraint t_example_cw_pk primary key ( id ),
  constraint t_example_cw_fk foreign key ( idt ) references t_example_type_cw (id)
);

create table t_example_cw_log
  as
    select * from t_example_cw;

insert into t_example_cw(id, idt, day_create)
with a as ( select n as n 
  						from generate_series(1, 100000) n )
select 
	n,
	cast((random() * 3) as int8), -- random value 0..3
	now()
from a;

select * from t_example_cw
  fetch first 10 rows only;

-- delete and insert journal
with moved_rows as (
 delete from t_example_cw where idt = 0 returning *
)
insert into t_example_cw_log select * from moved_rows;

select * from t_example_cw_log
  fetch first 10 rows only;
