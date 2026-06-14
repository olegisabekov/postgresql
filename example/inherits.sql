drop table if exists t_example_car;
drop table if exists t_example_motorcycle;
drop table if exists t_example_drive;

create table t_example_drive
(
  id integer not null,
  day_create timestamp not null default localtimestamp,
  constraint t_example_drive_pk primary key ( id )
);

create table t_example_car
(
  name varchar(30) not null,
  constraint t_example_car_pk primary key ( id )
) inherits(t_example_drive);

create table t_example_motorcycle
(
  name varchar(30) not null,
  constraint t_example_motorcycle_pk primary key ( id )
) inherits(t_example_drive);


insert into t_example_drive values(1, now());

insert into t_example_car values(1, now(), 'BOBIK');
insert into t_example_car values(1, now(), 'TOSI');
insert into t_example_car values(2, now(), 'TOSI');

insert into t_example_motorcycle values(1, now(), 'URAL');

select * from t_example_drive limit 20;
select * from t_example_car limit 20;
select * from t_example_motorcycle limit 20;

-- select tableoid::regclass, id, day_create from t_example_drive;

explain ( analyze true, buffers true )
select p.relname, d.id, d.day_create
from t_example_drive d
  join pg_class p on d.tableoid = p.oid
where d.id > 0;

explain ( analyze true, buffers true )
select p.relname, d.id, d.day_create
from t_example_drive d
  join pg_class p on d.tableoid = p.oid
where d.id = 2;

explain ( analyze true, buffers true )
select p.relname, d.id, d.day_create
from only t_example_drive d
  join pg_class p on d.tableoid = p.oid
where d.id = 1;
