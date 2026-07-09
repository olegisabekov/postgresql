select 
  conrelid::regclass table, 
  conname, 
  contype, 
  condeferrable, 
  convalidated
  from pg_constraint
--  where conname = ''
;
