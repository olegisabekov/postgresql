-- проверяем функционалтный индекс, ежедневная средняя температура за период 
explain analyze
with
 p as ( select
 					'rdate' as name_rdata, -- sensor date incoming
 					'temperature' as name_temerature,
 					103 as ons_id
      ),
 list_days as ( select day from generate_series(to_date( '01.04.2026', 'dd.mm.yyyy' ), to_date( '05.04.2026', 'dd.mm.yyyy' ), '1 day'::interval) day),
 d as materialized (
 				select
				 		pe.id,
						pe.group_level,
						pt.day as rdate,
						pe.day_create
				  from one_param op
				    cross join p
    				join one_param_ext pe on pe.op_id = op.id
    				join one_param_date pt on pt.id = pe.id and op.name = p.name_rdata
  			where op.ons_id = p.ons_id
  			  and pt.day in ( select day from list_days )
			),
 t as materialized (
          select
 						pe.id,
						pe.group_level,
						pf.value_float as temperature,
						pe.day_create
				  from one_param op
				    cross join p
    				join one_param_ext pe on pe.op_id = op.id
    				join one_param_number pf on pf.id = pe.id and op.name = p.name_temerature
  			where op.ons_id = p.ons_id
			)
select
		d.rdate,
		round(avg(temperature)::numeric, 2) as avg_temperature
	from d
  join t on d.group_level = t.group_level
group by d.rdate
order by d.rdate desc;
