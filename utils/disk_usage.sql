-- Finding the largest databases in your cluster
-- Performance Snippets
-- Disk usage Works with PostgreSQL
-- >=8.2
select d.datname as name,  pg_catalog.pg_get_userbyid(d.datdba) as owner,
    case when pg_catalog.has_database_privilege(d.datname, 'connect')
        then pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
        else 'no access'
    end as size
from pg_catalog.pg_database d
    order by
    case when pg_catalog.has_database_privilege(d.datname, 'connect')
        then pg_catalog.pg_database_size(d.datname)
        else null
    end desc -- nulls first
    limit 20;
