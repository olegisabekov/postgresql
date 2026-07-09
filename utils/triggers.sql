select 
  tgrelid::regclass tab, 
  tgconstrindid::regclass index, 
  tgname, 
  tgfoid::regproc as function_name, 
  tgtype t,
  case tgtype & 66 when 2 then 'BEFORE ' when 64 then 'INSTEAD OF ' else 'AFTER ' end || 
    case tgtype & 60
      when 4  then 'INSERT'
      when 8  then 'DELETE'
      when 16 then 'UPDATE'
      when 20 then 'INSERT UPDATE'
      when 32 then 'TRUNCATE'
    else '?' end || ' FOR EACH ' || case when tgtype & 1 = 1 then 'ROW' else 'STATEMENT' end as firing_conditions, 
    tgenabled e, 
    tgisinternal i, 
    tgdeferrable d, 
    tginitdeferred id 
  from pg_trigger;
