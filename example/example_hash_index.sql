create table t_example_type_hash
(
  id int8 not null,
  name varchar(20) not null,
  constraint t_example_type_hash_pk primary key ( id )
);

insert into t_example_type_hash values(0, 'trash');
insert into t_example_type_hash values(1, 'one');
insert into t_example_type_hash values(2, 'two');

create table t_example_hash
(
  id integer not null,
  idt int8 not null,
  day_create timestamp not null default localtimestamp,
  constraint t_example_hash_pk primary key ( id ),
  constraint t_example_hash_fk foreign key ( idt ) references t_example_type_hash (id)
);

select * from t_example_hash;

insert into t_example_hash(id, idt, day_create)
with a as ( select n as n 
  						from generate_series(1, 100000) n )
select 
	n,
	cast((random() * 2) as int8), -- random value 0..2
	now()
from a;

-- full scan
explain ( analyze true, buffers true )
  select * from t_example_hash
    where idt = 0;
    
create index t_example_hash_inx on t_example_hash using hash(idt);

-- index ready
explain ( analyze true, buffers true )
  select * from t_example_hash
    where idt = 0;

vacuum analyze;

drop table t_example_hash;
drop table t_example_type_hash;