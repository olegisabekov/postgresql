-- 
drop function get_number_float;
CREATE function get_number_float( p_group_level bigint, p_name varchar) returns float
as
$$
declare
  v_result float;
begin
	select pf.value into v_result
		from one_param op
		join one_param_ext ope on op.id = ope.op_id
		join one_param_float pf on ope.id = pf.id and op.name = p_name
		where ope.group_level = p_group_level;
	return v_result;
end;
$$
language plpgsql;

explain analyze
with
 p as ( select
          'rdate' as name_rdata, -- sensor date incoming
 					'test' as name_test,
 					200 as ons_id
      ),
 list_days as ( select day from generate_series(to_date( '01.03.2026', 'dd.mm.yyyy' ), to_date( '08.04.2026', 'dd.mm.yyyy' ), '1 day'::interval) day),
 d as (
 				select
						ope.group_level,
            opt.day as rdate,
            p.name_test
				  from one_param op
				    cross join p
    				join one_param_ext ope on ope.op_id = op.id
            join one_param_date opt on opt.id = ope.id
  			where op.name = p.name_rdata
          and opt.day in ( select day from list_days )
          and ope.ons_id = p.ons_id
				  )
select
		d.rdate,
		round(avg(get_number_float(p_group_level => d.group_level, p_name => d.name_test))::numeric, 2) as avg_test
	from d
group by d.rdate
order by d.rdate desc;
