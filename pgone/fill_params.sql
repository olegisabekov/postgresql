drop view vi_sensor_test;
drop procedure p_add_sensor_test;

create view vi_sensor_test( value, rdate, state ) as
  select 
      test,
      rdate,
      state
    from f_get_one_param_number(200);

create or replace procedure p_add_sensor_test(p_ons_id smallint, p_test float, p_rdate timestamp, p_state integer)
as
$fiud_sensor_test$
declare
  v_grp_lev_id integer;
begin
  if( p_ons_id is null )then
    raise exception 'value p_ons_id is not null!';
  end if;
  insert into one_param_grp_lev( id ) values( null ) returning id into v_grp_lev_id;
  insert into viud_one_param_float( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'test', v_grp_lev_id, p_rdate::date, p_test);
  insert into viud_one_param_integer( ons_id, name, group_level, day_begin, value ) values( p_ons_id, 'state', v_grp_lev_id, p_rdate::date, p_state );
  insert into viud_one_param_date( ons_id, name, group_level, day_begin, value_ts ) values( p_ons_id, 'rdate', v_grp_lev_id, p_rdate::date, p_rdate );
end
$fiud_sensor_test$
language plpgsql;
    
create or replace function fiud_sensor_test() returns trigger as
$fiud_sensor_test$
declare
  c_ons_id constant smallint := coalesce(p_ons_id, 200);
  v_grp_lev_id integer;
begin
  if( tg_op = 'INSERT' )then
    call p_add_sensor_test(c_ons_id, new.value, new.rdate, new.state);
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

begin isolation level read committed;
insert into vi_sensor_test( value, rdate, state )
  with ds as (
    SELECT generate_series(
      '2023-01-01 00:00'::timestamp, -- Start
      '2026-04-05 00:00'::timestamp, -- End
      '1 minute'::interval            -- Step
    ) AS h )
    select random( 10.0, 40.9 ) as value, h as rdate, 0 as state from ds;
commit;

insert into one_namespace( id, name, description ) values( 201, 'test2', 'test2');

begin isolation level read committed;
do $$
declare
    rec record;
    c_ons_id constant smallint := 201;
begin
  for rec in 
    with ds as (
    SELECT generate_series(
      '2024-01-01 00:00'::timestamp, -- Start
      '2026-04-05 00:00'::timestamp, -- End
      '1 minute'::interval            -- Step
    ) AS h )
    select random( 10.0, 40.9 ) as value, h as rdate, 0 as state from ds loop
    call p_add_sensor_test(c_ons_id, rec.value, rec.rdate, rec.state);
  end loop;
end $$;
commit;
