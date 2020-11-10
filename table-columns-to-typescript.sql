--
-- Get every table and it's columns as typescript properties
--
with cteTables as (
  select (
      '"' || tbls."table_schema" || '"."' || tbls."table_name" || '"'
    )::regclass as "TableReg",
    (
      '"' || tbls."table_schema" || '"."' || tbls."table_name" || '"'
    ) as "TableFull",
    *
  from "information_schema"."tables" tbls
  where tbls."table_type" = 'BASE TABLE'
    and tbls."table_schema" not in ('pg_catalog', 'information_schema', 'auth')
)
select tbls."TableFull",
  array_to_string(
    array(
      select cols."column_name"::TEXT || ': ' || (
          case
            when (
              cols."column_name" = 'id'
              or cols."column_name" like '%Id'
            ) then 'ID'
            when cols."udt_name" in ('text', 'varchar', 'uuid', 'date') then 'string'
            when cols."udt_name" in ('bool') then 'boolean'
            when cols."udt_name" in (
              'float4',
              'float8',
              'int2',
              'int4',
              'int8',
              'numeric'
            ) then 'number'
            when cols."udt_name" in ('timestamp', 'timestamptz') then 'Date'
            else 'unknown'
          end
        ) || (
          case
            when is_nullable::BOOLEAN then ' | null'
            else ''
          end
        ) || ';'
      from "information_schema"."columns" cols
      where cols."table_schema" = tbls."table_schema"
        and cols."table_name" = tbls."table_name"
      order by cols."ordinal_position"
    ),
    ' '
  )
from cteTables tbls
order by tbls."TableFull";