--
-- Exact BTree
--
create index if not exists "table_column_idx" ON "schema"."table" using btree (("column"));

--
-- Full Text Search
--
create index if not exists "table_column_idx_trgm" ON "schema"."table" using gin (("column")) public.gin_trgm_ops);
