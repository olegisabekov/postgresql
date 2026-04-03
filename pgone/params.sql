drop view viud_one_param_date;
drop view viud_one_param_number;
drop view viud_one_param_money;
drop view viud_one_param_string;
drop function f_add_one_param;
drop table one_param_date;
drop table one_param_string;
drop table one_param_number;
drop table one_param_money;
drop table one_param_ext;
drop table one_param_grp_lev;
drop table one_param;
drop table one_namespace;
drop sequence seq_one_param_group_level;

create table one_namespace
(
  id smallint not null,
  name varchar(200) not null,
  description varchar(4000),
  constraint one_param_type_id_pk primary key ( id ) using index tablespace one_index
) tablespace one_data;

create table one_param
(
  id serial,
  ons_id smallint,
  name varchar(200),
  constraint one_param_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_ons_id_fk foreign key ( ons_id ) references one_namespace (id)
) tablespace one_data;

create unique index one_param_opt_name_ons_id_inx on one_param ( ons_id, name ) tablespace one_index;
create index one_param_name_inx on one_param ( name ) tablespace one_index;

create sequence seq_one_param_group_level start with 1 increment by 1 cache 20;

create table one_param_grp_lev
(
  id integer not null,
  constraint one_param_grp_lev_id_pk primary key ( id ) using index tablespace one_index
) tablespace one_data;  

create or replace function fi_one_param_grp_lev() returns trigger as 
$$
begin
  if( new.id is null )then
    new.id := nextval( 'seq_one_param_group_level' );
  end if;
  return new;
end;
$$ language plpgsql;

create trigger ti_one_param_grp_lev
  before insert on one_param_grp_lev
  for each row
    execute function fi_one_param_grp_lev();

create table one_param_ext
(
  id serial,
  op_id integer not null,
  group_level integer,
  day_create timestamp not null default localtimestamp,
  day_begin date not null,
  day_end date default null,
  constraint one_param_ext_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_ext_id_fk foreign key ( op_id ) references one_param (id),
  constraint one_param_ext_group_level_fk foreign key ( group_level ) references one_param_grp_lev (id)
) tablespace one_data;

create index one_param_ext_opid_inx on one_param_ext( op_id );
create index one_param_ext_dc_inx on one_param_ext( day_create );

create table one_param_number
(
  id integer,
  value_int integer,
  value_float float,
  constraint one_param_number_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_number_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_number_id_inx on one_param_number( id ) tablespace one_index;

create table one_param_string
(
  id integer,
  value_smal varchar(100),
  value_medium varchar(1000),
  value_big varchar(2000),
  constraint one_param_string_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_string_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_string_id_inx on one_param_string( id ) tablespace one_index;

create table one_param_money
(
  id integer,
  value money,
  constraint one_param_money_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_money_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_money_id_inx on one_param_money( id ) tablespace one_index;

create table one_param_date
(
  id integer,
  value_date date,
  value_ts timestamp,
  day date generated always as (date_trunc('day', value_ts)),
  constraint one_param_date_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_date_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_date_id_inx on one_param_date( id ) tablespace one_index;
create index one_param_date_day_inx on one_param_date((date_trunc('day', value_ts)::date));

create or replace function f_add_one_param( p_ons_id smallint, p_name varchar)
returns integer as $$
declare
  result integer;
begin
  with inserted as
	  ( insert into one_param( ons_id, name ) values( p_ons_id, p_name ) on conflict (ons_id, name) do nothing returning id )
	select id into result
		from inserted
	union all
		select id from one_param where ons_id = p_ons_id and name = p_name;
	return result;
end;
$$ language plpgsql;

create or replace function fiud_one_param_number() returns trigger as
$fiud_one_param_number$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    v_op_id := f_add_one_param(new.ons_id, new.name);
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_number( id, value_int, value_float ) values( v_ope_id, new.value_int, new.value_float );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_number set value_int = new.value_int, value_float = new.value_float
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_number$
language plpgsql;

create or replace view viud_one_param_number( id, ons_id, name, group_level, value_int, value_float ) as
  select 
   ope.id,
   op.ons_id,
   op.name,
   ope.group_level,
   opn.value_int,
   opn.value_float
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_number opn on opn.id = ope.id;

create trigger tiud_one_param_number
   instead of insert or update or delete on viud_one_param_number
   for each row
   execute procedure fiud_one_param_number();

create or replace function fiud_one_param_string() returns trigger as
$fiud_one_param_string$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    v_op_id := f_add_one_param(new.ons_id, new.name);
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_string values( v_ope_id, new.value_smal, new.value_medium, new.value_big );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_string set value_smal = new.value_smal, value_medium = new.value_medium, value_big = new.value_big
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_string$
language plpgsql;

create or replace view viud_one_param_string( id, ons_id, name, group_level, value_smal, value_medium, value_big ) as
  select 
   ope.id,
   op.ons_id,
   op.name,
   ope.group_level,
   ops.value_smal,
   ops.value_medium,
   ops.value_big
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_string ops on ops.id = ope.id;

create trigger tiud_one_param_string
   instead of insert or update or delete on viud_one_param_string
   for each row
   execute procedure fiud_one_param_string();

create or replace function fiud_one_param_money() returns trigger as
$fiud_one_param_money$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    v_op_id := f_add_one_param(new.ons_id, new.name);
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_money values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_money set value = new.value
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_money$
language plpgsql;

create or replace view viud_one_param_money( id, ons_id, name, group_level, value ) as
  select 
   op.id,
   op.ons_id,
   op.name,
   ope.group_level,
   opm.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_money opm on opm.id = ope.id;

create trigger tiud_one_param_money
   instead of insert or update or delete on viud_one_param_money
   for each row
   execute procedure fiud_one_param_money();

\echo "date"

create or replace function fiud_one_param_date() returns trigger as
$fiud_one_param_date$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    v_op_id := f_add_one_param(new.ons_id, new.name);
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_date values( v_ope_id, new.value_date, new.value_ts );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_date set value_date = new.value_date, value_ts = new.value_ts
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_date$
language plpgsql;

create or replace view viud_one_param_date( id, ons_id, name, group_level, value_date, value_ts, day ) as
  select 
   op.id,
   op.ons_id,
   op.name,
   ope.group_level,
   opd.value_date,
   opd.value_ts,
   opd.day
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_date opd on opd.id = ope.id;

create trigger tiud_one_param_date
   instead of insert or update or delete on viud_one_param_date
   for each row
   execute procedure fiud_one_param_date();

grant all on one_namespace to users_haunte;
grant all on one_param to users_haunte;
grant all on one_param_ext to users_haunte;
grant all on one_param_number to users_haunte;
grant all on viud_one_param_string to users_haunte;
grant all on viud_one_param_date to users_haunte;
