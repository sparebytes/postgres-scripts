--
-- Delete trigger from tables by name
--
CREATE OR REPLACE FUNCTION public.deleteTriggerFromTables(triggName text) RETURNS text AS $$ DECLARE
    triggTableRecord RECORD;
BEGIN
    FOR triggTableRecord IN SELECT distinct(event_object_table) from information_schema.triggers where trigger_name = triggName LOOP
        RAISE NOTICE 'Dropping trigger: % on table: %', triggName, triggTableRecord.event_object_table;
        EXECUTE 'DROP TRIGGER "' || triggName || '" ON "' || triggTableRecord.event_object_table || '";';
    END LOOP;
    RETURN 'done';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- -- Example:
-- select deleteTriggerFromTables('ZAudit');


--
-- Count triggers by name
--
select 
    count(*) as tgCount,
    tgName
from pg_trigger,pg_proc where
 pg_proc.oid=pg_trigger.tgfoid
group by tgName
order by COUNT(*) desc;