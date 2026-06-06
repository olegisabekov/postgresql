-- General Table Size Information
-- Performance Snippets
-- Disk usage Works with PostgreSQL
-- >=9.2
-- This will report size information for all tables, in both raw bytes and "pretty" form.
with lst as (
    select c.oid,nspname as table_schema, relname as table_name
              , c.reltuples as row_estimate
              , pg_total_relation_size(c.oid) as total_bytes
              , pg_indexes_size(c.oid) as index_bytes
              , pg_total_relation_size(reltoastrelid) as toast_bytes
          from pg_class c
          left join pg_namespace n on n.oid = c.relnamespace
          where relkind = 'r' ),
    t as ( select *, total_bytes-index_bytes-coalesce(toast_bytes,0) as table_bytes from lst )        
select *, 
	pg_size_pretty(total_bytes) as total,
  pg_size_pretty(index_bytes) as index,
  pg_size_pretty(toast_bytes) as toast,
  pg_size_pretty(table_bytes) as table
  from t;

 /*
размер пользовательских таблиц
pg_total_relation_size(relid)	Total size: Main data + Indexes + TOAST (oversized data).
pg_table_size(relid)	Table data only: Main data + TOAST (excludes indexes).
pg_relation_size(relid)	Raw table only: Just the main heap file (excludes indexes and TOAST).
pg_indexes_size(relid)	Indexes only: Combined size of all indexes on that table.
*/
