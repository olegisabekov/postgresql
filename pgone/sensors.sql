\i drop_sensors.sql

create procedure add_one_param_number(
  p_ons_id smallint,
  p_temperature float default null,
  p_tstate integer default null,
  p_humidity float default null,
  p_hstate integer default null,
  p_altitude float default null,
  p_astate integer default null,
  p_pressure float default null,
  p_pstate integer default null,
  p_vcc float default null,
  p_state integer default null,
  p_rdate timestamp default null
)
as $$
declare
  v_grp_lev_id integer;
begin
  if(p_ons_id is null)then
    raise exception 'value p_ons_id is not null!';
  end if;
  insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
  if(p_temperature is not null)then
    insert into viud_one_param_float( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'temperature', v_grp_lev_id, p_rdate::date, p_temperature);
  end if;
  if(p_tstate is not null)then
    insert into viud_one_param_integer( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'tstate', v_grp_lev_id, p_rdate::date, p_tstate );
  end if;
  if(p_humidity is not null)then
    insert into viud_one_param_float( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'humidity', v_grp_lev_id, p_rdate::date, p_humidity);
  end if;
  if(p_hstate is not null)then
    insert into viud_one_param_integer( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'hstate', v_grp_lev_id, p_rdate::date, p_hstate );
  end if;
  if(p_altitude is not null)then
    insert into viud_one_param_float( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'altitude', v_grp_lev_id, p_rdate::date, p_altitude);
  end if;
  if(p_astate is not null)then
    insert into viud_one_param_integer( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'astate', v_grp_lev_id, p_rdate::date, p_astate );
  end if;
  if(p_pressure is not null)then
    insert into viud_one_param_float( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'pressure', v_grp_lev_id, p_rdate::date, p_pressure);
  end if;
  if(p_pstate is not null)then
    insert into viud_one_param_integer( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'pstate', v_grp_lev_id, p_rdate::date, p_pstate );
  end if;
  if(p_vcc is not null)then
    insert into viud_one_param_float( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'vcc', v_grp_lev_id, p_rdate::date, p_vcc);
  end if;
  if(p_state is not null)then
    insert into viud_one_param_integer( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'state', v_grp_lev_id, p_rdate::date, p_state );
  end if;
  if(p_rdate is not null)then
    insert into viud_one_param_date( ons_id, name, group_level, day_begin, value_ts ) values( p_ons_id, 'rdate', v_grp_lev_id, p_rdate::date, p_rdate );
  end if;
end;
$$ language plpgsql;

create function f_get_one_param_number( p_ons_id integer, p_report_date date default current_date )
returns table (
        group_level bigint,
        temperature float,
        tstate integer,
        humidity float,
        hstate integer,
        altitude float,
        astate integer,
        pressure float,
        pstate integer,
        rdate timestamp,
        vcc float,
        state integer,
        test float
      ) as $$
begin
  return query
  with
	  a as (
	    select
	          op.name,
            ope.group_level,
            opn.value as value_int,
            cast(null as float) as value_float,
            cast(null as timestamp) as value_ts
          from one_param op
            join one_param_ext ope on ope.op_id = op.id
            join one_param_integer opn on opn.id = ope.id
          where ope.ons_id = p_ons_id
            and ope.day_begin = p_report_date
      union all
          select
            op.name,
            ope.group_level,
            null,
            opf.value,
            null
          from one_param op
            join one_param_ext ope on ope.op_id = op.id
            join one_param_float opf on opf.id = ope.id
          where ope.ons_id = p_ons_id
            and ope.day_begin = p_report_date
      union all
          select
            op.name,
            ope.group_level,
            null,
            null,
            opd.value_ts
          from one_param op
            join one_param_ext ope on ope.op_id = op.id
            join one_param_date opd on opd.id = ope.id
          where ope.ons_id = p_ons_id
            and ope.day_begin = p_report_date
          )
    select
          a.group_level,
          max(case when name = 'temperature' then value_float end) temperature,
          max(case when name = 'tstate' then value_int end) tstate,
          max(case when name = 'humidity' then value_float end) humidity,
          max(case when name = 'hstate' then value_int end) hstate,
          max(case when name = 'altitude' then value_float end) altitude,
          max(case when name = 'astate' then value_int end) astate,
          max(case when name = 'pressure' then value_float end) pressure,
          max(case when name = 'pstate' then value_int end) pstate,
          max(case when name = 'rdate' then value_ts end) rdate,
          max(case when name = 'vcc' then value_float end) vcc,
          max(case when name = 'state' then value_int end) state,
          max(case when name = 'test' then value_float end) test
        from a
      group by a.group_level;
end;
$$ language plpgsql;

create or replace view vi_sensor_t8( temerature, humidity, rdate, vcc, state ) as
  select
      temperature,
      humidity,
      rdate,
      vcc,
      state
    from f_get_one_param_number(101);

create or replace function fiud_sensor_t8() returns trigger as
$fiud_sensor_t8$
declare
  c_ons_id constant integer := 101;
begin
  if( tg_op = 'INSERT' )then
    call add_one_param_number(
      p_ons_id => c_ons_id::smallint,
      p_temperature => round( cast( new.temerature as numeric ), 2 ),
      p_humidity => round( cast( new.humidity as numeric ), 2 ),
      p_vcc => round( cast( new.vcc as numeric ), 4 ),
      p_state => new.state,
      p_rdate => new.rdate - interval '4 hours');
    return new;
  elsif( tg_op = 'UPDATE' )then
    return null;
  elsif( tg_op = 'DELETE' )then
    return null;
  end if;
  return null;
end
$fiud_sensor_t8$
language plpgsql;

create or replace trigger t_sensor_t8
   instead of insert on vi_sensor_t8
   for each row
     execute procedure fiud_sensor_t8();

create or replace view vi_sensor_t7( temerature, tstate, humidity, hstate, pressure, pstate, rdate, vcc, state ) as
  select
      temperature,
      tstate,
      humidity,
      hstate,
      pressure,
      pstate,
      rdate,
      vcc,
      state
    from f_get_one_param_number(100);

create or replace function fiud_sensor_t7() returns trigger as
$fiud_sensor_t7$
declare
  c_ons_id constant integer := 100;
begin
  if( tg_op = 'INSERT' )then
    call add_one_param_number(
      p_ons_id => c_ons_id::smallint,
      p_temperature => round( cast( new.temerature as numeric ), 2 ),
      p_tstate => new.tstate,
      p_humidity => round( cast( new.humidity as numeric ), 2 ),
      p_hstate => new.hstate,
      p_pressure => round( cast( new.pressure as numeric ), 2 ),
      p_pstate => new.pstate,
      p_vcc => round( cast( new.vcc as numeric ), 4 ),
      p_state => new.state,
      p_rdate => new.rdate - interval '4 hours');
    return new;
  elsif( tg_op = 'UPDATE' )then
    return null;
  elsif( tg_op = 'DELETE' )then
    return null;
  end if;
  return null;
end
$fiud_sensor_t7$
language plpgsql;

create or replace trigger ti_sensor_t7
   instead of insert on vi_sensor_t7
   for each row
    execute procedure fiud_sensor_t7();

create or replace view vi_sensor_t3( temerature, tstate, altitude, astate, pressure, pstate, rdate, vcc, state ) as
  select
      temperature,
      tstate,
      altitude,
      astate,
      pressure,
      pstate,
      rdate,
      vcc,
      state
    from f_get_one_param_number(103);

create or replace function fiud_sensor_t3() returns trigger as
$fiud_sensor_t3$
declare
  c_ons_id constant integer := 103;
begin
  if( tg_op = 'INSERT' )then
    call add_one_param_number(
      p_ons_id => c_ons_id::smallint,
      p_temperature => round( cast( new.temerature as numeric ), 2 ),
      p_tstate => new.tstate,
      p_altitude => round( cast( new.altitude as numeric ), 2 ),
      p_astate => new.astate,
      p_pressure => round( cast( new.pressure as numeric ), 2 ),
      p_pstate => new.pstate,
      p_vcc => round( cast( new.vcc as numeric ), 4 ),
      p_state => new.state,
      p_rdate => new.rdate - interval '4 hours');
    return new;
  elsif( tg_op = 'UPDATE' )then
    return null;
  elsif( tg_op = 'DELETE' )then
    return null;
  end if;
  return null;
end
$fiud_sensor_t3$
language plpgsql;

create or replace trigger ti_sensor_t3
   instead of insert on vi_sensor_t3
   for each row
    execute procedure fiud_sensor_t3();

/*
Flatlet/Sensor/T5/#
*/

create or replace view vi_sensor_t5( temperature, humidity, rdate, vcc, state ) as
  select
      temperature,
      humidity,
      rdate,
      vcc,
      state
    from f_get_one_param_number(105);

create or replace function fi_sensor_t5() returns trigger as
$fi_sensor_t5$
declare
  c_ons_id constant smallint := 105;
begin
  call add_one_param_number(
      p_ons_id => c_ons_id,
      p_temperature => round( cast( new.temperature as numeric ), 2 ),
      p_humidity => round( cast( new.humidity as numeric ), 2 ),
      p_vcc => round( cast( new.vcc as numeric ), 4 ),
      p_state => new.state,
      p_rdate => new.rdate - interval '4 hours');
  return new;
end
$fi_sensor_t5$
language plpgsql;

create or replace trigger ti_sensor_t5
   instead of insert on vi_sensor_t5
   for each row
    execute procedure fi_sensor_t5();

/*
Flatlet/Sensor/K1/#
*/
create or replace view vi_sensor_k1( temperature, humidity, rdate, vcc, state ) as
  select
      temperature,
      humidity,
      rdate,
      vcc,
      state
    from f_get_one_param_number(102);

create or replace function fi_sensor_k1() returns trigger as
$fi_sensor_k1$
declare
  c_ons_id constant smallint := 102;
begin
  call add_one_param_number(
      p_ons_id => c_ons_id,
      p_temperature => round( cast( new.temperature as numeric ), 2 ),
      p_humidity => round( cast( new.humidity as numeric ), 2 ),
      p_vcc => round( cast( new.vcc as numeric ), 4 ),
      p_state => new.state,
      p_rdate => new.rdate - interval '4 hours');
  return new;
end
$fi_sensor_k1$
language plpgsql;

create or replace trigger ti_sensor_k1
   instead of insert on vi_sensor_k1
   for each row
    execute procedure fi_sensor_k1();

create or replace view vi_sensor_t6( temperature, tstate, pressure, pstate, rdate, vcc, state ) as
  select
      temperature,
      tstate,
      pressure,
      pstate,
      rdate,
      vcc,
      state
    from f_get_one_param_number(106);

create or replace function fi_sensor_t6() returns trigger as
$fi_sensor_t6$
declare
  c_ons_id constant smallint := 106;
begin
  call add_one_param_number(
    p_ons_id => c_ons_id,
    p_temperature => round( cast( new.temperature as numeric ), 2 ),
    p_tstate => new.tstate,
    p_pressure => round( cast( new.pressure as numeric ), 2 ),
    p_pstate => new.pstate,
    p_vcc => round( cast( new.vcc as numeric ), 4 ),
    p_state => new.state,
    p_rdate => new.rdate - interval '4 hours');
  return new;
end
$fi_sensor_t6$
language plpgsql;

create or replace trigger ti_sensor_t6
   instead of insert on vi_sensor_t6
   for each row
    execute procedure fi_sensor_t6();

/*
Flatlet/Sensor/T9/VCC 4.0
Flatlet/Sensor/T9/Datetime 1774293549
Flatlet/Sensor/T9/Temperature/Internal/State 0
Flatlet/Sensor/T9/Temperature/Internal/C 24.0
Flatlet/Sensor/T9/Humidity/Internal/State 0
Flatlet/Sensor/T9/Humidity/Internal/% 34.8
*/
create or replace view vi_sensor_T9( temperature, tstate, humidity, hstate, rdate, vcc, state ) as
  select
      temperature,
      tstate,
      humidity,
      hstate,
      rdate,
      vcc,
      state
    from f_get_one_param_number(109);

create or replace function fi_sensor_T9() returns trigger as
$fi_sensor_T9$
declare
  c_ons_id constant integer := 109;
begin
  call add_one_param_number(
    p_ons_id => c_ons_id::smallint,
    p_temperature => round( cast( new.temperature as numeric ), 2 ),
    p_tstate => new.tstate,
    p_humidity => round( cast( new.humidity as numeric ), 2 ),
    p_hstate => new.hstate,
    p_vcc => round( cast( new.vcc as numeric ), 4 ),
    p_state => new.state,
    p_rdate => new.rdate - interval '4 hours');
  return new;
end
$fi_sensor_T9$
language plpgsql;

create or replace trigger ti_sensor_T9
   instead of insert on vi_sensor_T9
   for each row
    execute procedure fi_sensor_T9();

grant execute on procedure add_one_param_number to users_haunte;
grant execute on function f_get_one_param_number to users_haunte;
grant all on vi_sensor_t8 to users_haunte;
grant all on vi_sensor_t7 to users_haunte;
grant all on vi_sensor_t3 to users_haunte;
grant all on vi_sensor_k1 to users_haunte;
grant all on vi_sensor_t5 to users_haunte;
grant all on vi_sensor_t6 to users_haunte;
grant all on vi_sensor_t9 to users_haunte;

insert into one_namespace( id, name, description ) values( 100, 'Flatlet/Sensor/T7/#', 'В коридоре');
insert into one_namespace( id, name, description ) values( 101, 'Flatlet/Sensor/T8/#', 'В гостиной');
insert into one_namespace( id, name, description ) values( 103, 'Flatlet/Sensor/T3/#', 'В маленькой спальне');
insert into one_namespace( id, name, description ) values( 105, 'Flatlet/Sensor/T5/#', 'В девичьей');
insert into one_namespace( id, name, description ) values( 102, 'Flatlet/Sensor/K1/#', 'За окном');
insert into one_namespace( id, name, description ) values( 106, 'Flatlet/Sensor/T6/#', 'В большой спальне');
insert into one_namespace( id, name, description ) values( 109, 'Flatlet/Sensor/T9/#', 'На кухне');

