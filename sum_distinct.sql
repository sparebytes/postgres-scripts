
-- SEE https://stackoverflow.com/a/63458730

CREATE OR REPLACE FUNCTION "public"."sum_distinct_func" (double precision, pg_catalog.anyelement, double precision)
RETURNS double precision AS $body$ SELECT case when $3 is not null then COALESCE($1, 0) + $3 else $1 end $body$
LANGUAGE 'sql';
CREATE AGGREGATE "public"."sum_distinct" (pg_catalog."any", double precision)(SFUNC = sum_distinct_func, STYPE = double precision);

CREATE OR REPLACE FUNCTION "public"."sum_distinct_func" (bigint, pg_catalog.anyelement, bigint)
RETURNS bigint AS $body$ SELECT case when $3 is not null then COALESCE($1, 0) + $3 else $1 end $body$
LANGUAGE 'sql';
CREATE AGGREGATE "public"."sum_distinct" (pg_catalog."any", bigint)(SFUNC = sum_distinct_func, STYPE = bigint);

CREATE OR REPLACE FUNCTION "public"."sum_distinct_func" (numeric, pg_catalog.anyelement, numeric)
RETURNS numeric AS $body$ SELECT case when $3 is not null then COALESCE($1, 0) + $3 else $1 end $body$
LANGUAGE 'sql';
CREATE AGGREGATE "public"."sum_distinct" (pg_catalog."any", numeric)(SFUNC = sum_distinct_func, STYPE = numeric);