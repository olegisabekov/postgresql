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
  name varchar(30) not null
) inherits(t_example_drive);

create table t_example_motorcycle
(
  name varchar(30) not null
) inherits(t_example_drive);


insert into t_example_drive values(1, now());

insert into t_example_car values(1, now(), 'BOBIK');
insert into t_example_car values(1, now(), 'TOSI');

insert into t_example_motorcycle values(1, now(), 'URAL');

select tableoid::regclass, id, day_create
from t_example_drive;
