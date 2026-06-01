-- помним оракл неявное преобразование пробуем
create table t_example_err_to_number
(
  id varchar(10) not null,
  day_create timestamp not null default localtimestamp,
  text varchar(20),
  constraint t_example_err_to_number_pk primary key ( id )
);

select * from t_example_err_to_number;

create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1 + random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;


insert into t_example_err_to_number(id, day_create, text)
with a as ( select to_char(n, 'FM999') as n 
  						from generate_series(1, 100) n )
select 
	lpad(n, 10, '0') as ids,
	now(),
	random_string(20) as text
from a;

explain ( analyze true, buffers true )
  select * from t_example_err_to_number
	  where id = '0000000000';

-- error хм, и это хорошо	  
select * from t_example_err_to_number
	  where id = 0;

select to_number(id, '9999999999') from t_example_err_to_number;

-- error IMMUTABLE
create index t_example_err_to_number_inx on t_example_err_to_number(to_number(id, '9999999999'));

-- udf immutable function
create function s2n(p_str varchar) returns integer as $$
 select to_number(p_str, '9999999999')
$$ language sql immutable;

create function n2s(p_val integer) returns varchar as $$
 select lpad(to_char(p_val, 'FM999'), 10, '0');
$$ language sql immutable;

select s2n(id) from t_example_err_to_number;

drop index t_example_err_to_number_inx;

-- function index to number
create index t_example_err_to_number_inx on t_example_err_to_number(s2n(id));

-- index ready
explain ( analyze true, buffers true )
select * from t_example_err_to_number
	  where s2n(id) = 1;

-- full scan
explain ( analyze true, buffers true )
select * from t_example_err_to_number
	  where id = n2s(12);

drop table t_example_err_to_number;