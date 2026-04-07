-- проверяем функционалтный индекс, ежедневная средний вакум за период 
--explain analyze
with
 p as ( select
 					'rdate' as name_rdata, -- sensor date incoming
 					'test' as name_test,
 					200 as ons_id
      ),
 list_days as ( select day from generate_series(to_date( '01.03.2026', 'dd.mm.yyyy' ), to_date( '01.05.2026', 'dd.mm.yyyy' ), '1 day'::interval) day),
 d as materialized (
 				select
				 		ope.id,
						ope.group_level,
						pt.day as rdate,
						ope.day_create
				  from one_param op
				    cross join p
    				join one_param_ext ope on ope.op_id = op.id
    				join one_param_date pt on pt.id = ope.id and op.name = p.name_rdata
  			where ope.ons_id = p.ons_id
  			  and pt.day in ( select day from list_days )
			),
 t as materialized (
          select
 						pe.id,
						pe.group_level,
						pf.value_float as test,
						pe.day_create
				  from one_param op
				    cross join p
    				join one_param_ext pe on pe.op_id = op.id
    				join one_param_number pf on pf.id = pe.id and op.name = p.name_test
  			where pe.ons_id = p.ons_id
			)
select
		d.rdate,
		round(avg(test)::numeric, 2) as avg_test
	from d
  join t on d.group_level = t.group_level
group by d.rdate
order by d.rdate desc;
