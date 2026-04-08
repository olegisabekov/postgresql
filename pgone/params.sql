\i dropall.sql

create table one_namespace
(
  id smallint not null,
  name varchar(200) not null,
  description varchar(4000),
  constraint one_param_type_id_pk primary key ( id )
);

create table one_param
(
  id serial,
  name varchar(200) not null,
  constraint one_param_id_pk primary key ( id )
);

create unique index one_param_opt_name_inx on one_param ( name );

create sequence seq_one_param_group_level start with 1 increment by 1 cache 20;

create table one_param_grp_lev
(
  id bigint not null,
  constraint one_param_grp_lev_id_pk primary key ( id )
);

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

create sequence seq_one_param_ext start with 1 increment by 1 cache 20;

create table one_param_ext
(
  id bigint not null,
  op_id integer not null,
  ons_id smallint not null,
  group_level bigint,
  day_create timestamp not null default localtimestamp,
  day_begin date not null,
  day_end date default null,
  constraint one_param_ext_id_pk primary key ( id ),
  constraint one_param_ext_id_fk foreign key ( op_id ) references one_param (id),
  constraint one_param_ext_ons_id_fk foreign key ( ons_id ) references one_namespace (id),
  constraint one_param_ext_group_level_fk foreign key ( group_level ) references one_param_grp_lev (id)
) tablespace one_data;

create index one_param_ext_ons_id on one_param_ext using brin(op_id, ons_id);
create unique index one_param_ext_group_level_inx on one_param_ext (op_id, group_level);
create index one_param_ext_dc_inx on one_param_ext( day_create );

create or replace function fi_one_param_ext_id() returns trigger as 
$$
begin
  if( new.id is null )then
    new.id := nextval( 'seq_one_param_ext' );
  end if;
  if( new.day_create is null )then
    new.day_create := localtimestamp;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger ti_one_param_ext
  before insert on one_param_ext
  for each row
    execute function fi_one_param_ext_id();

create table one_param_integer
(
  id bigint,
  value integer,
  constraint one_param_integer_id_pk primary key ( id ),
  constraint one_param_integer_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create table one_param_float
(
  id bigint,
  value float,
  constraint one_param_float_id_pk primary key ( id ),
  constraint one_param_float_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create table one_param_string
(
  id bigint,
  value varchar(4000),
  constraint one_param_string_id_pk primary key ( id ),
  constraint one_param_string_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create table one_param_money
(
  id bigint,
  value money,
  constraint one_param_money_id_pk primary key ( id ),
  constraint one_param_money_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create table one_param_date
(
  id integer,
  value_ts timestamp,
  day date generated always as (date_trunc('day', value_ts)),
  constraint one_param_date_id_pk primary key ( id ),
  constraint one_param_date_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_date_id_inx on one_param_date( id );
create index one_param_date_day_inx on one_param_date((date_trunc('day', value_ts)::date));

create or replace function f_add_one_param( p_name varchar)
returns integer as $$
declare
  result integer;
begin
  with inserted as
	  ( insert into one_param( name ) values( p_name ) on conflict (name) do nothing returning id )
	select id into result
		from inserted
	union all
		select id from one_param where name = p_name;
	return result;
end;
$$ language plpgsql;

create or replace function fiud_one_param_integer() returns trigger as
$fiud_one_param_integer$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    v_op_id := f_add_one_param(new.name);
    insert into one_param_ext( op_id, ons_id, group_level, day_begin ) values( v_op_id, new.ons_id, new.group_level, case when new.day_begin is null then current_date else new.day_begin end ) returning id into v_ope_id;
    insert into one_param_integer( id, value ) values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_integer set value = new.value
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_integer$
language plpgsql;

create or replace view viud_one_param_integer( id, ons_id, name, group_level, day_begin, value ) as
  select 
      ope.id,
      ope.ons_id,
      op.name,
      ope.group_level,
      ope.day_begin,
      opn.value
    from one_param op
      join one_param_ext ope on ope.op_id = op.id
      join one_param_integer opn on opn.id = ope.id;

create trigger tiud_one_param_integer
   instead of insert or update or delete on viud_one_param_integer
   for each row
   execute procedure fiud_one_param_integer();

create or replace function fiud_one_param_float() returns trigger as
$fiud_one_param_float$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    v_op_id := f_add_one_param(new.name);
    insert into one_param_ext( op_id, ons_id, group_level, day_begin ) 
      values( v_op_id, new.ons_id, new.group_level, case when new.day_begin is null then current_date else new.day_begin end ) returning id into v_ope_id;
    insert into one_param_float( id, value ) values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_float set value = new.value
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_float$
language plpgsql;

create or replace view viud_one_param_float( id, ons_id, name, group_level, day_begin, value ) as
  select 
   ope.id,
   ope.ons_id,
   op.name,
   ope.group_level,
   ope.day_begin,
   opn.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_float opn on opn.id = ope.id;

create trigger tiud_one_param_float
   instead of insert or update or delete on viud_one_param_float
   for each row
   execute procedure fiud_one_param_float();

create or replace function fiud_one_param_string() returns trigger as
$fiud_one_param_string$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    v_op_id := f_add_one_param(new.name);
    insert into one_param_ext( op_id, ons_id, group_level, day_begin ) 
      values( v_op_id, new.ons_id, new.group_level, case when new.day_begin is null then current_date else new.day_begin end ) returning id into v_ope_id;
    insert into one_param_string values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_string set value_smal = new.value
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

create or replace view viud_one_param_string( id, ons_id, name, group_level, day_begin, value ) as
  select 
   ope.id,
   ope.ons_id,
   op.name,
   ope.group_level,
   ope.day_begin,
   ops.value
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
    v_op_id := f_add_one_param(new.name);
    insert into one_param_ext( op_id, ons_id, group_level, day_begin ) 
      values( v_op_id, new.ons_id, new.group_level, case when new.day_begin is null then current_date else new.day_begin end ) returning id into v_ope_id;
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

create or replace view viud_one_param_money( id, ons_id, name, group_level, day_begin, value ) as
  select 
   ope.id,
   ope.ons_id,
   op.name,
   ope.group_level,
   ope.day_begin,
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
    v_op_id := f_add_one_param(new.name);
    insert into one_param_ext( op_id, ons_id, group_level, day_begin ) 
      values( v_op_id, new.ons_id, new.group_level, case when new.day_begin is null then current_date else new.day_begin end ) returning id into v_ope_id;
    insert into one_param_date values( v_ope_id, new.value_ts );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_date set value_ts = new.value_ts
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

create or replace view viud_one_param_date( id, ons_id, name, group_level, day_begin, value_ts, day ) as
  select 
   ope.id,
   ope.ons_id,
   op.name,
   ope.group_level,
   ope.day_begin,
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
grant all on one_param_integer to users_haunte;
grant all on one_param_float to users_haunte;
grant all on viud_one_param_string to users_haunte;
grant all on viud_one_param_date to users_haunte;
