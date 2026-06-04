create or replace function dump_my_mem() returns void as
$$
declare
   r record;
begin
   for r in
      select name, ident, level, total_bytes
      from pg_backend_memory_contexts
   loop
      raise notice '% % % %',
         repeat('  ', r.level - 1),
         r.name,
         r.total_bytes,
         r.ident;
   end loop;
end;
$$ language plpgsql;
