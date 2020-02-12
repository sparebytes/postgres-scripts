--
-- Get every table and it's columns
--
with cteTables as (
select
     ('"'||tbls."table_schema"||'"."'||tbls."table_name"||'"')::regclass as "TableReg",
     ('"'||tbls."table_schema"||'"."'||tbls."table_name"||'"') as "TableFull",
     *
	from "information_schema"."tables" tbls
	where tbls."table_type" = 'BASE TABLE'
	and tbls."table_schema" NOT IN ('pg_catalog', 'information_schema', 'auth')
)
select
	tbls."TableFull",
	array(
		select cols."column_name"::text
		from "information_schema"."columns" cols
		where cols."table_schema" = tbls."table_schema"
		and cols."table_name" = tbls."table_name"
		order by cols."ordinal_position"
	)
from cteTables tbls
order by tbls."TableFull"
;


--
-- Find columns of a certain type
--
select
-- 	cols."ordinal_position",
	('"'||cols."table_schema"||'"."'||cols."table_name"||'"."'||cols."column_name"||'"') as "TableReg",
	cols.data_type
from "information_schema"."columns" cols
where cols."data_type" like '%xxxxxxxxxxxxxxxxxxxxxxxxxxxx%'
and cols."table_schema" NOT IN ('pg_catalog', 'information_schema', 'auth')
order by
	cols."table_schema",
	cols."table_name",
	cols."ordinal_position"


--
-- Find columns that reference another column
--

with primaryColumns("Schema", "Table", "Column") as (VALUES
	-- ('schema', 'table', 'column')
),
cteColumns as (
	SELECT DISTINCT
		R.TABLE_SCHEMA::text,
		R.TABLE_NAME::text,
		R.COLUMN_NAME::text
	FROM
		INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE u
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG 
			AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA 
			AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE R ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG 
			AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA 
			AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME 
		INNER JOIN primaryColumns on
			U.TABLE_SCHEMA = primaryColumns."Schema"
			AND U.TABLE_NAME = primaryColumns."Table"
			AND U.COLUMN_NAME = primaryColumns."Column"
	ORDER BY 
		R.TABLE_SCHEMA::text,
		R.TABLE_NAME::text,
		R.COLUMN_NAME::text
)
select
	R.TABLE_SCHEMA as "Schema",
	R.TABLE_NAME as "Table",
	array_to_string(array_agg(R.COLUMN_NAME), ',') as "Columns"
from cteColumns as R
GROUP BY 
	R.TABLE_SCHEMA,
	R.TABLE_NAME
ORDER BY 
	R.TABLE_SCHEMA::text,
	R.TABLE_NAME::text;
