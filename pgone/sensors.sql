create or replace view viud_sensor_t8( temerature, humidity, rdate, vcc, state ) as
  select
   	  max(opft.value) as temerature,
   	  max(opfh.value) as humidity,
   	  max(oprd.value) as rdate,
   	  max(vcc.value) as vcc,
      max(opis.value) as state
    from one_param op
      join one_param_type opt on opt.id = op.opt_id
      join one_param_ext ope on ope.op_id = op.id
   		left join one_param_timestamp oprd on oprd.id = ope.id and op.name = 'rdate'
   		left join one_param_float opft on opft.id = ope.id and op.name = 'temerature'
	 		left join one_param_float opfh on opfh.id = ope.id and op.name = 'humidity'
      left join one_param_integer opis on opis.id = ope.id and op.name = 'state'
	 		left join one_param_float vcc on vcc.id = ope.id and op.name = 'vcc'
      where op.opt_id = 101
   	group by ope.group_level;

create or replace function fiud_sensor_t8() returns trigger as
$fiud_sensor_t8$
declare
  c_opt_id constant integer := 101;
  v_grp_lev_id integer;
begin
  if( tg_op = 'INSERT' )then
    insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'state', v_grp_lev_id, new.state );
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'temerature', v_grp_lev_id, round( cast( new.temerature as numeric ), 2 ));
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'humidity', v_grp_lev_id, round( cast( new.humidity as numeric ), 2 ));
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'vcc', v_grp_lev_id, round( cast( new.vcc as numeric ), 4 ));
    insert into viud_one_param_timestamp( opt_id, name, group_level, value ) values( c_opt_id, 'rdate', v_grp_lev_id, new.rdate - interval '4 hours' );
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

create or replace trigger tiud_sensor_t8
   instead of insert on viud_sensor_t8
   for each row
     execute procedure fiud_sensor_t8();

create or replace view viud_sensor_t7( temerature, tstate, humidity, hstate, pressure, pstate, rdate, vcc, state ) as
  select
   	  max(opft.value) as temerature,
   	  max(opit.value) as tstate,
   	  max(opfh.value) as humidity,
   	  max(opih.value) as hstate,
      max(opfp.value) as pressure,
   	  max(opip.value) as pstate,
   	  max(oprd.value) as rdate,
   	  max(vcc.value) as vcc,
      max(opis.value) as state
    from one_param op
   		join one_param_ext ope on ope.op_id = op.id
   		left join one_param_timestamp oprd on oprd.id = ope.id and op.name = 'rdate'
   		left join one_param_float opft on opft.id = ope.id and op.name = 'temerature'
	 		left join one_param_float opfh on opfh.id = ope.id and op.name = 'humidity'
 	 		left join one_param_float opfp on opfp.id = ope.id and op.name = 'pressure'
      left join one_param_integer opis on opis.id = ope.id and op.name = 'state'
	 		left join one_param_integer opit on opit.id = ope.id and op.name = 'tstate'
	 		left join one_param_integer opih on opih.id = ope.id and op.name = 'hstate'
 	 		left join one_param_integer opip on opip.id = ope.id and op.name = 'pstate'
	 		left join one_param_float vcc on vcc.id = ope.id and op.name = 'vcc'
      where op.opt_id = 100
   	group by ope.group_level;

create or replace function fiud_sensor_t7() returns trigger as
$fiud_sensor_t7$
declare
  c_opt_id constant integer := 100;
  v_grp_lev_id integer;
begin
  if( tg_op = 'INSERT' )then
    insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'tstate', v_grp_lev_id, new.tstate );
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'hstate', v_grp_lev_id, new.hstate );
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'pstate', v_grp_lev_id, new.pstate );
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'state', v_grp_lev_id, new.state );
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'temerature', v_grp_lev_id, round( cast ( new.temerature as numeric ), 2 ));
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'humidity', v_grp_lev_id, round( cast ( new.humidity as numeric ), 2 ));
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'pressure', v_grp_lev_id, round( cast ( new.pressure as numeric ), 2 ));
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'vcc', v_grp_lev_id, round( cast( new.vcc as numeric ), 4 ));
    insert into viud_one_param_timestamp( opt_id, name, group_level, value ) values( c_opt_id, 'rdate', v_grp_lev_id, new.rdate - interval '4 hours' );
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
   instead of insert on viud_sensor_t7
   for each row
    execute procedure fiud_sensor_t7();

create or replace view viud_sensor_t3( temerature, tstate, altitude, astate, pressure, pstate, rdate, vcc, state ) as
  select
   	  max(opft.value) as temerature,
   	  max(opit.value) as tstate,
   	  max(opfa.value) as altitude,
   	  max(opia.value) as astate,
      max(opfp.value) as pressure,
   	  max(opip.value) as pstate,
   	  max(oprd.value) as rdate,
   	  max(vcc.value) as vcc,
      max(opis.value) as state
    from one_param op
   		join one_param_ext ope on ope.op_id = op.id
   		left join one_param_timestamp oprd on oprd.id = ope.id and op.name = 'rdate'
   		left join one_param_float opft on opft.id = ope.id and op.name = 'temerature'
	 		left join one_param_float opfa on opfa.id = ope.id and op.name = 'altitude'
 	 		left join one_param_float opfp on opfp.id = ope.id and op.name = 'pressure'
      left join one_param_integer opis on opis.id = ope.id and op.name = 'state'
	 		left join one_param_integer opit on opit.id = ope.id and op.name = 'tstate'
	 		left join one_param_integer opia on opia.id = ope.id and op.name = 'astate'
 	 		left join one_param_integer opip on opip.id = ope.id and op.name = 'pstate'
	 		left join one_param_float vcc on vcc.id = ope.id and op.name = 'vcc'
      where op.opt_id = 103
   	group by ope.group_level;

create or replace function fiud_sensor_t3() returns trigger as
$fiud_sensor_t3$
declare
  c_opt_id constant integer := 103;
  v_grp_lev_id integer;
begin
  if( tg_op = 'INSERT' )then
    insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'tstate', v_grp_lev_id, new.tstate );
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'astate', v_grp_lev_id, new.astate );
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'pstate', v_grp_lev_id, new.pstate );
    insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'state', v_grp_lev_id, new.state );
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'temerature', v_grp_lev_id, round( cast ( new.temerature as numeric ), 2 ));
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'altitude', v_grp_lev_id, round( cast ( new.altitude as numeric ), 2 ));
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'pressure', v_grp_lev_id, round( cast ( new.pressure as numeric ), 2 ));
    insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'vcc', v_grp_lev_id, round( cast( new.vcc as numeric ), 4 ));
    insert into viud_one_param_timestamp( opt_id, name, group_level, value ) values( c_opt_id, 'rdate', v_grp_lev_id, new.rdate - interval '4 hours' );
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
   instead of insert on viud_sensor_t3
   for each row
    execute procedure fiud_sensor_t3();

/*
Flatlet/Sensor/T5/#
*/

create or replace view vi_sensor_t5( temperature, humidity, rdate, vcc, state ) as
  select
   	  max(opft.value) as temperature,
   	  max(opfh.value) as humidity,
   	  max(oprd.value) as rdate,
   	  max(vcc.value) as vcc,
      max(opis.value) as state
    from one_param op
   		join one_param_ext ope on ope.op_id = op.id
   		left join one_param_timestamp oprd on oprd.id = ope.id and op.name = 'rdate'
   		left join one_param_float opft on opft.id = ope.id and op.name = 'temperature'
	 		left join one_param_float opfh on opfh.id = ope.id and op.name = 'humidity'
      left join one_param_integer opis on opis.id = ope.id and op.name = 'state'
	 		left join one_param_float vcc on vcc.id = ope.id and op.name = 'vcc'
      where op.opt_id = 105
   	group by ope.group_level;

create or replace function fi_sensor_t5() returns trigger as
$fi_sensor_t5$
declare
  c_opt_id constant integer := 105;
  v_grp_lev_id integer;
begin
  insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'state', v_grp_lev_id, new.state );
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'temperature', v_grp_lev_id, round( cast ( new.temperature as numeric ), 2 ));
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'humidity', v_grp_lev_id, round( cast ( new.humidity as numeric ), 2 ));
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'vcc', v_grp_lev_id, round( cast( new.vcc as numeric ), 4 ));
  insert into viud_one_param_timestamp( opt_id, name, group_level, value ) values( c_opt_id, 'rdate', v_grp_lev_id, new.rdate - interval '4 hours' );
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
   	  max(opft.value) as temperature,
   	  max(opfh.value) as humidity,
   	  max(oprd.value) as rdate,
   	  max(vcc.value) as vcc,
      max(opis.value) as state
    from one_param op
   		join one_param_ext ope on ope.op_id = op.id
   		left join one_param_timestamp oprd on oprd.id = ope.id and op.name = 'rdate'
   		left join one_param_float opft on opft.id = ope.id and op.name = 'temperature'
	 		left join one_param_float opfh on opfh.id = ope.id and op.name = 'humidity'
      left join one_param_integer opis on opis.id = ope.id and op.name = 'state'
	 		left join one_param_float vcc on vcc.id = ope.id and op.name = 'vcc'
      where op.opt_id = 102
   	group by ope.group_level;

create or replace function fi_sensor_k1() returns trigger as
$fi_sensor_k1$
declare
  c_opt_id constant integer := 102;
  v_grp_lev_id integer;
begin
  insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'state', v_grp_lev_id, new.state );
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'temperature', v_grp_lev_id, round( cast ( new.temperature as numeric ), 2 ));
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'humidity', v_grp_lev_id, round( cast ( new.humidity as numeric ), 2 ));
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'vcc', v_grp_lev_id, round( cast( new.vcc as numeric ), 4 ));
  insert into viud_one_param_timestamp( opt_id, name, group_level, value ) values( c_opt_id, 'rdate', v_grp_lev_id, new.rdate - interval '4 hours' );
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
   	  max(opft.value) as temperature,
   	  max(opit.value) as tstate,
      max(opfp.value) as pressure,
   	  max(opip.value) as pstate,
   	  max(oprd.value) as rdate,
   	  max(vcc.value) as vcc,
      max(opis.value) as state
    from one_param op
   		join one_param_ext ope on ope.op_id = op.id
   		left join one_param_timestamp oprd on oprd.id = ope.id and op.name = 'rdate'
   		left join one_param_float opft on opft.id = ope.id and op.name = 'temperature'
 	 		left join one_param_float opfp on opfp.id = ope.id and op.name = 'pressure'
      left join one_param_integer opis on opis.id = ope.id and op.name = 'state'
	 		left join one_param_integer opit on opit.id = ope.id and op.name = 'tstate'
 	 		left join one_param_integer opip on opip.id = ope.id and op.name = 'pstate'
	 		left join one_param_float vcc on vcc.id = ope.id and op.name = 'vcc'
      where op.opt_id = 106
   	group by ope.group_level;

create or replace function fi_sensor_t6() returns trigger as
$fi_sensor_t6$
declare
  c_opt_id constant integer := 106;
  v_grp_lev_id integer;
begin
  insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'tstate', v_grp_lev_id, new.tstate );
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'pstate', v_grp_lev_id, new.pstate );
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'state', v_grp_lev_id, new.state );
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'temperature', v_grp_lev_id, round( cast ( new.temperature as numeric ), 2 ));
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'pressure', v_grp_lev_id, round( cast ( new.pressure as numeric ), 2 ));
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'vcc', v_grp_lev_id, round( cast( new.vcc as numeric ), 4 ));
  insert into viud_one_param_timestamp( opt_id, name, group_level, value ) values( c_opt_id, 'rdate', v_grp_lev_id, new.rdate - interval '4 hours' );
  return new;
end
$fi_sensor_t6$
language plpgsql;

create or replace trigger ti_sensor_t6
   instead of insert on vi_sensor_t6
   for each row
    execute procedure fi_sensor_t6();

/*
Flatlet/Sensor/R1/VCC 3.3
Flatlet/Sensor/R1/Distance/cm 165
Flatlet/Sensor/R1/FilterDistance/cm 151
Flatlet/Sensor/R1/DataValid 1
Flatlet/Sensor/R1/OldZone 2
Flatlet/Sensor/R1/CurrentZone 3
Flatlet/Sensor/R1/Sleeping 0
Flatlet/Sensor/R1/NameCurZone Рядом
Flatlet/Sensor/R1/RadarState 1
Flatlet/Sensor/R1/Datetime 1772556328
*/

create or replace view vi_sensor_r1( distance, filter_distance, data_valid, old_zone, current_zone, name_curzone, datetime, sleeping, radarstate, vcc ) as
  select
   	  max(opid.value) as distance,
   	  max(opif.value) as filter_distance,
      max(opidv.value) as data_valid,
   	  max(opioz.value) as old_zone,
      max(opicz.value) as current_zone,
      max(opmn.value) as name_curzone,
   	  max(oprd.value) as datetime,
      max(opis.value) as sleeping,
      max(opirs.value) as radarstate,
   	  max(vcc.value) as vcc
    from one_param op
   		join one_param_ext ope on ope.op_id = op.id
   		left join one_param_timestamp oprd on oprd.id = ope.id and op.name = 'datetime'
      left join one_param_integer opid on opid.id = ope.id and op.name = 'distance'
	 		left join one_param_integer opif on opif.id = ope.id and op.name = 'filter_distance'
 	 		left join one_param_integer opidv on opidv.id = ope.id and op.name = 'data_valid'
 	 		left join one_param_integer opioz on opioz.id = ope.id and op.name = 'old_zone'
 	 		left join one_param_integer opicz on opicz.id = ope.id and op.name = 'current_zone'
 	 		left join one_param_mediumstr opmn on opmn.id = ope.id and op.name = 'name_curzone'
 	 		left join one_param_integer opis on opis.id = ope.id and op.name = 'sleeping'
 	 		left join one_param_integer opirs on opirs.id = ope.id and op.name = 'radarstate'
	 		left join one_param_float vcc on vcc.id = ope.id and op.name = 'vcc'
      where op.opt_id = 107
   	group by ope.group_level;

create or replace function fi_sensor_r1() returns trigger as
$fi_sensor_r1$
declare
  c_opt_id constant integer := 107;
  v_grp_lev_id integer;
begin
  insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'distance', v_grp_lev_id, new.distance );
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'filter_distance', v_grp_lev_id, new.filter_distance );
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'data_valid', v_grp_lev_id, new.data_valid );
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'old_zone', v_grp_lev_id, new.old_zone );
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'current_zone', v_grp_lev_id, new.current_zone );
  insert into viud_one_param_mediumstr( opt_id, name, group_level, value ) values( c_opt_id, 'name_curzone', v_grp_lev_id, new.name_curzone );
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'sleeping', v_grp_lev_id, new.sleeping );
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'radarstate', v_grp_lev_id, new.radarstate );
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'vcc', v_grp_lev_id, round( cast( new.vcc as numeric ), 4 ));
  insert into viud_one_param_timestamp( opt_id, name, group_level, value ) values( c_opt_id, 'datetime', v_grp_lev_id, new.datetime);
  return new;
end
$fi_sensor_r1$
language plpgsql;

create or replace trigger ti_sensor_r1
   instead of insert on vi_sensor_r1
   for each row
    execute procedure fi_sensor_r1();

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
   	  max(opft.value) as temperature,
      max(opit.value) as tstate,
   	  max(opfh.value) as humidity,
      max(opih.value) as hstate,
   	  max(oprd.value) as rdate,
   	  max(vcc.value) as vcc,
      max(opis.value) as state
    from one_param op
   		join one_param_ext ope on ope.op_id = op.id
   		left join one_param_timestamp oprd on oprd.id = ope.id and op.name = 'rdate'
   		left join one_param_float opft on opft.id = ope.id and op.name = 'temperature'
 	 		left join one_param_integer opit on opit.id = ope.id and op.name = 'tstate'
	 		left join one_param_float opfh on opfh.id = ope.id and op.name = 'humidity'
      left join one_param_integer opih on opih.id = ope.id and op.name = 'hstate'
	 		left join one_param_float vcc on vcc.id = ope.id and op.name = 'vcc'      
      left join one_param_integer opis on opis.id = ope.id and op.name = 'state'
      where op.opt_id = 109
   	group by ope.group_level;

create or replace function fi_sensor_T9() returns trigger as
$fi_sensor_T9$
declare
  c_opt_id constant integer := 109;
  v_grp_lev_id integer;
begin
  insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'state', v_grp_lev_id, new.state );
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'temperature', v_grp_lev_id, round( cast ( new.temperature as numeric ), 2 ));
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'tstate', v_grp_lev_id, new.tstate );
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'humidity', v_grp_lev_id, round( cast ( new.humidity as numeric ), 2 ));
  insert into viud_one_param_integer( opt_id, name, group_level, value ) values( c_opt_id, 'hstate', v_grp_lev_id, new.hstate );
  insert into viud_one_param_float( opt_id, name, group_level, value ) values( c_opt_id, 'vcc', v_grp_lev_id, round( cast( new.vcc as numeric ), 4 ));
  insert into viud_one_param_timestamp( opt_id, name, group_level, value ) values( c_opt_id, 'rdate', v_grp_lev_id, new.rdate  - interval '4 hours' );
  return new;
end
$fi_sensor_T9$
language plpgsql;

create or replace trigger ti_sensor_T9
   instead of insert on vi_sensor_T9
   for each row
    execute procedure fi_sensor_T9();


grant all on viud_sensor_t8 to users_haunte;
grant all on viud_sensor_t7 to users_haunte;
grant all on viud_sensor_t3 to users_haunte;
grant all on vi_sensor_t4 to users_haunte;
grant all on vi_sensor_k1 to users_haunte;
grant all on vi_sensor_t5 to users_haunte;
grant all on vi_sensor_t6 to users_haunte;
grant all on vi_sensor_r1 to users_haunte;
grant all on vi_sensor_t9 to users_haunte;

insert into one_param_type( id, name, description ) values( 100, 'Flatlet/Sensor/T7/#', 'В коридоре');
insert into one_param_type( id, name, description ) values( 101, 'Flatlet/Sensor/T8/#', 'В гостиной');
insert into one_param_type( id, name, description ) values( 103, 'Flatlet/Sensor/T3/#', 'В маленькой спальне');
insert into one_param_type( id, name, description ) values( 104, 'Flatlet/Sensor/T4/#', 'На кухне');
insert into one_param_type( id, name, description ) values( 105, 'Flatlet/Sensor/T5/#', 'В девичьей');
insert into one_param_type( id, name, description ) values( 102, 'Flatlet/Sensor/K1/#', 'За окном');
insert into one_param_type( id, name, description ) values( 106, 'Flatlet/Sensor/T6/#', 'В большой спальне');
insert into one_param_type( id, name, description ) values( 107, 'Flatlet/Sensor/R1/#', 'Детектор кожаных мешков');
insert into one_param_type( id, name, description ) values( 109, 'Flatlet/Sensor/T9/#', 'На кухне');
