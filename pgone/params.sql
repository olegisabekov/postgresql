drop view viud_one_param_float;
drop view viud_one_param_date;
drop view viud_one_param_timestamp;
drop view viud_one_param_money;
drop view viud_one_param_integer;
drop view viud_one_param_smalstr;
drop view viud_one_param_mediumstr;
drop view viud_one_param_bigstr;
drop table one_param_float;
drop table one_param_date;
drop table one_param_timestamp;
drop table one_param_bigstr;
drop table one_param_mediumstr;
drop table one_param_smalstr;
drop table one_param_integer;
drop table one_param_money;
drop table one_param_ext;
drop table one_param_grp_lev;
drop table one_param;
drop table one_param_type;
drop sequence seq_one_param_group_level;

create table one_param_type
(
  id smallint not null,
  name varchar(200) not null,
  description varchar(4000),
  constraint one_param_type_id_pk primary key ( id ) using index tablespace one_index
) tablespace one_data;

create table one_param
(
  id serial,
  opt_id smallint,
  name varchar(200),
  constraint one_param_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_opt_id_fk foreign key ( opt_id ) references one_param_type (id)
) tablespace one_data;

create unique index one_param_opt_name_opt_id_inx on one_param ( opt_id, name ) tablespace one_index;
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

create table one_param_integer
(
  id integer,
  value integer,
  constraint one_param_integer_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_integer_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_integer_id_inx on one_param_integer( id ) tablespace one_index;

create table one_param_smalstr
(
  id integer,
  value varchar(100),
  constraint one_param_smalstr_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_smalstr_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_smalstr_id_inx on one_param_smalstr( id ) tablespace one_index;

create table one_param_mediumstr
(
  id integer,
  value varchar(1000),
  constraint one_param_mediumstr_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_mediumstr_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_mediumstr_id_inx on one_param_mediumstr( id ) tablespace one_index;

create table one_param_bigstr
(
  id integer,
  value varchar(2000),
  constraint one_param_bigstr_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_bigstr_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_bigstr_id_inx on one_param_bigstr( id ) tablespace one_index;

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
  value date,
  constraint one_param_date_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_date_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_date_id_inx on one_param_date( id ) tablespace one_index;

create table one_param_timestamp
(
  id integer,
  value timestamp,
  day date generated always as (date_trunc('day', value)),
  constraint one_param_timestamp_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_timestamp_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_timestamp_date_inx on one_param_timestamp((date_trunc('day', value)));

create table one_param_float
(
  id integer,
  value float,
  constraint one_param_float_id_pk primary key ( id ) using index tablespace one_index,
  constraint one_param_float_id_fk foreign key ( id ) references one_param_ext(id) on delete cascade
) tablespace one_data;

create index one_param_float_id_inx on one_param_float( id ) tablespace one_index;

create or replace function fiud_one_param_integer() returns trigger as
$fiud_one_param_integer$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    select id into v_op_id
      from one_param
        where name = new.name
          and opt_id = new.opt_id;
    if not found then
      insert into one_param( opt_id, name ) values( new.opt_id, new.name ) returning id into v_op_id;
    end if;
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_integer values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_smalstr set value = new.value
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

create or replace view viud_one_param_integer( id, opt_id, name, group_level, value ) as
  select 
   ope.id,
   op.opt_id,
   op.name,
   ope.group_level,
   opi.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_integer opi on opi.id = ope.id;

create trigger tiud_one_param_integer 
   instead of insert or update or delete on viud_one_param_integer
   for each row
   execute procedure fiud_one_param_integer();

create or replace function fiud_one_param_smalstr() returns trigger as
$fiud_one_param_smalstr$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    select id into v_op_id
      from one_param
        where name = new.name
          and opt_id = new.opt_id;
    if not found then
      insert into one_param( opt_id, name ) values( new.opt_id, new.name ) returning id into v_op_id;
    end if;
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_smalstr values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_smalstr set value = new.value
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_smalstr$
language plpgsql;

create or replace view viud_one_param_smalstr( id, opt_id, name, group_level, value ) as
  select 
   ope.id,
   op.opt_id,
   op.name,
   ope.group_level,
   opss.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_smalstr opss on opss.id = ope.id;

create trigger tiud_one_param_smalstr
   instead of insert or update or delete on viud_one_param_smalstr
   for each row
   execute procedure fiud_one_param_smalstr();

create or replace function fiud_one_param_mediumstr() returns trigger as
$fiud_one_param_mediumstr$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    select id into v_op_id
      from one_param
        where name = new.name
          and opt_id = new.opt_id;
    if not found then
      insert into one_param( opt_id, name ) values( new.opt_id, new.name ) returning id into v_op_id;
    end if;
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_mediumstr values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_mediumstr set value = new.value
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_mediumstr$
language plpgsql;

create or replace view viud_one_param_mediumstr( id, opt_id, name, group_level, value ) as
  select 
   op.id,
   op.opt_id,
   op.name,
   ope.group_level,
   opms.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_mediumstr opms on opms.id = ope.id;

create trigger tiud_one_param_mediumstr
   instead of insert or update or delete on viud_one_param_mediumstr
   for each row
   execute procedure fiud_one_param_mediumstr();

create or replace function fiud_one_param_bigstr() returns trigger as
$fiud_one_param_bigstr$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    select id into v_op_id
      from one_param
        where name = new.name
          and opt_id = new.opt_id;
    if not found then
      insert into one_param( opt_id, name ) values( new.opt_id, new.name ) returning id into v_op_id;
    end if;
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_bigstr values( v_ope_id, new.value );
    return new;
  end if;
end
$fiud_one_param_bigstr$
language plpgsql;

create or replace view viud_one_param_bigstr( id, opt_id, name, group_level, value ) as
  select 
   op.id,
   op.opt_id,
   op.name,
   ope.group_level,
   opbs.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_bigstr opbs on opbs.id = ope.id;

create trigger tiud_one_param_bigstr
   instead of insert or update or delete on viud_one_param_bigstr
   for each row
   execute procedure fiud_one_param_bigstr();

create or replace function fiud_one_param_money() returns trigger as
$fiud_one_param_money$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    select id into v_op_id
      from one_param
        where name = new.name
          and opt_id = new.opt_id;
    if not found then
      insert into one_param( opt_id, name ) values( new.opt_id, new.name ) returning id into v_op_id;
    end if;
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

create or replace view viud_one_param_money( id, opt_id, name, group_level, value ) as
  select 
   op.id,
   op.opt_id,
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

create or replace function fiud_one_param_date() returns trigger as
$fiud_one_param_date$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    select id into v_op_id
      from one_param
        where name = new.name
          and opt_id = new.opt_id;
    if not found then
      insert into one_param( opt_id, name ) values( new.opt_id, new.name ) returning id into v_op_id;
    end if;
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_date values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_date set value = new.value
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

create or replace view viud_one_param_date( id, opt_id, name, group_level, value ) as
  select 
   op.id,
   op.opt_id,
   op.name,
   ope.group_level,
   opd.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_date opd on opd.id = ope.id;

create trigger tiud_one_param_date
   instead of insert or update or delete on viud_one_param_date
   for each row
   execute procedure fiud_one_param_date();

\echo "timestamp"

create or replace function fiud_one_param_timestamp() returns trigger as
$fiud_one_param_timestamp$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    select id into v_op_id
      from one_param
        where name = new.name
          and opt_id = new.opt_id;
    if not found then
      insert into one_param( opt_id, name ) values( new.opt_id, new.name ) returning id into v_op_id;
    end if;
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_timestamp values( v_ope_id, new.value );
    return new;
  elsif( tg_op = 'UPDATE' )then
    update one_param_timestamp set value = new.value
      where id = new.id;
    return new;
  elsif( tg_op = 'DELETE' )then
    delete from one_param_ext where id = old.id;
    return old;
  end if;
  return null;
end
$fiud_one_param_timestamp$
language plpgsql;

create or replace view viud_one_param_timestamp( id, opt_id, name, group_level, value ) as
  select 
   op.id,
   op.opt_id,
   op.name,
   ope.group_level,
   opd.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_timestamp opd on opd.id = ope.id;

create trigger tiud_one_param_timestamp
   instead of insert or update or delete on viud_one_param_timestamp
   for each row
   execute procedure fiud_one_param_timestamp();

\echo "float"

create or replace function fiud_one_param_float() returns trigger as
$fiud_one_param_float$
declare
  v_op_id integer;
  v_ope_id integer;
begin
  if( tg_op = 'INSERT' )then
    select id into v_op_id
      from one_param
        where name = new.name
          and opt_id = new.opt_id;
    if not found then
      insert into one_param( opt_id, name ) values( new.opt_id, new.name ) returning id into v_op_id;
    end if;
    insert into one_param_ext( op_id, group_level, day_begin ) values( v_op_id, new.group_level, current_date ) returning id into v_ope_id;
    insert into one_param_float values( v_ope_id, new.value );
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

create or replace view viud_one_param_float( id, opt_id, name, group_level, value ) as
  select 
   op.id,
   op.opt_id,
   op.name,
   ope.group_level,
   opf.value
   from one_param op
   join one_param_ext ope on ope.op_id = op.id
   join one_param_float opf on opf.id = ope.id;

create trigger tiud_one_param_float
   instead of insert or update or delete on viud_one_param_float
   for each row
   execute procedure fiud_one_param_float();

grant all on one_param_type to users_haunte;
grant all on one_param to users_haunte;
grant all on one_param_ext to users_haunte;
grant all on one_param_integer to users_haunte;
grant all on one_param_smalstr to users_haunte;
grant all on viud_one_param_integer to users_haunte;
grant all on viud_one_param_smalstr to users_haunte;
grant all on viud_one_param_mediumstr to users_haunte;
grant all on viud_one_param_bigstr to users_haunte;
grant all on viud_one_param_date to users_haunte;
grant all on viud_one_param_timestamp to users_haunte;
grant all on viud_one_param_float to users_haunte;
