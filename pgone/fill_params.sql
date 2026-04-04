drop view vi_sensor_test;

create view vi_sensor_test( value, rdate, state ) as
  select 
      test,
      rdate,
      state
    from f_get_one_param_number(cast(200 as smallint));

create or replace function fiud_sensor_test() returns trigger as
$fiud_sensor_test$
declare
  c_ons_id constant integer := 200;
  v_grp_lev_id integer;
begin
  if( tg_op = 'INSERT' )then
    insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
    insert into viud_one_param_number( ons_id, name, group_level, value_float ) values( c_ons_id::smallint, 'test', v_grp_lev_id, new.value);
    insert into viud_one_param_number( ons_id, name, group_level, value_int ) values( c_ons_id::smallint, 'state', v_grp_lev_id, new.state );
    insert into viud_one_param_date( ons_id, name, group_level, value_ts ) values( c_ons_id::smallint, 'rdate', v_grp_lev_id, new.rdate );
    return new;
  elsif( tg_op = 'UPDATE' )then
    return null;
  elsif( tg_op = 'DELETE' )then
    return null;
  end if;
  return null;
end
$fiud_sensor_test$
language plpgsql;

create or replace trigger t_sensor_test
   instead of insert on vi_sensor_test
   for each row
     execute procedure fiud_sensor_test();


grant all on vi_sensor_test to users_haunte;

insert into one_namespace( id, name, description ) values( 200, 'test', 'test');

insert into vi_sensor_test( value, rdate, state )
  with ds as (
    SELECT generate_series(
      '2026-04-01 00:00'::timestamp, -- Start
      '2027-01-01 00:00'::timestamp, -- End
      '1 hours'::interval            -- Step
    ) AS h )
    select random( 10.0, 40.9 ) as value, h as rdate, 0 as state from ds;
