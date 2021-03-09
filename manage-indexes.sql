--
-- RESET SEQUENCE
--
SELECT setval('YOUR_TABLE_id_seq', COALESCE((SELECT MAX(id)+1 FROM YOUR_TABLE), 1), false);

ALTER SEQUENCE serial RESTART WITH 105


--
-- Exact BTree
--
create index if not exists "table_column_idx" ON "schema"."table" using btree (("column"));

--
-- Full Text Search
--
create index if not exists "table_column_idx_trgm" ON "schema"."table" using gin (("column")) public.gin_trgm_ops);
