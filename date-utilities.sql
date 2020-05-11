
-- datediff years
create or replace function "public"."datediff_years"(beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return date_part('year', endTimestamp) - date_part('year', beginTimestamp);
end;
$$ language plpgsql;


-- datediff months
create or replace function "public"."datediff_months"(beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return datediff_years(beginTimestamp, endTimestamp) * 12 + (date_part('month', endTimestamp) - date_part('month', beginTimestamp));
end;
$$ language plpgsql;


-- datediff quarters
create or replace function "public"."datediff_quarters"(beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return floor(datediff_months(beginTimestamp, endTimestamp) / 3);
end;
$$ language plpgsql;


-- datediff days
create or replace function "public"."datediff_days"(beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return date_part('day', endTimestamp - beginTimestamp);
end;
$$ language plpgsql;


-- datediff weeks
create or replace function "public"."datediff_weeks"(beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return floor(datediff_days(beginTimestamp, endTimestamp) / 7);
end;
$$ language plpgsql;


-- datediff hours
create or replace function "public"."datediff_hours"(beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return datediff_days(beginTimestamp, endTimestamp) * 24 + date_part('hour', endTimestamp - beginTimestamp);
end;
$$ language plpgsql;

-- datediff minutes
create or replace function "public"."datediff_minutes"(beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return datediff_hours(beginTimestamp, endTimestamp) * 60 + date_part('minute', endTimestamp - beginTimestamp);
end;
$$ language plpgsql;

-- datediff seconds
create or replace function "public"."datediff_seconds"(beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return datediff_minutes(beginTimestamp, endTimestamp) * 60 + date_part('second', endTimestamp - beginTimestamp);
end;
$$ language plpgsql;

-- datediff
create or replace function "public"."datediff"(datePartName text, beginTimestamp timestamptz, endTimestamp timestamptz)
returns double precision AS $$
begin
    return (case
        when datePartName in ('yy', 'year', 'years')        then datediff_years(beginTimestamp, endTimestamp)
        when datePartName in ('qtr', 'quarter', 'quarter')  then datediff_quarters(beginTimestamp, endTimestamp)
        when datePartName in ('mm', 'month', 'months')      then datediff_months(beginTimestamp, endTimestamp)
        when datePartName in ('dd', 'day', 'days')          then datediff_days(beginTimestamp, endTimestamp)
        when datePartName in ('wk', 'week', 'weeks')        then datediff_weeks(beginTimestamp, endTimestamp)
        when datePartName in ('hh', 'hour', 'hours')        then datediff_hours(beginTimestamp, endTimestamp)
        when datePartName in ('mi', 'minute', 'minutes')    then datediff_minutes(beginTimestamp, endTimestamp)
        when datePartName in ('ss', 'second', 'seconds')    then datediff_seconds(beginTimestamp, endTimestamp)
        else null
    end);
end;
$$ language plpgsql;


-- dategrid
create or replace function "public"."dategrid"(
    "part" text,
    "beg" timestamptz,
    "end" timestamptz default null,
    "offset" interval default null,
    "format" text  default null
)
returns table(dateRangeLabel text, dateRangeBegin timestamptz, dateRangeEnd timestamptz) AS $$
begin
    return query with
    cteParams("ParamDateRangeType", "ParamBeginTimestamp", "ParamEndTimestamp", "ParamOffset", "DateRangeFormat") as (values
        ("part", "beg", "end", "offset", "format")
    --   ('hour',    date_trunc('year', CURRENT_TIMESTAMP - interval '1' year), date_trunc('year', CURRENT_TIMESTAMP), null, null, null),
    --   ('day',     date_trunc('year', CURRENT_TIMESTAMP - interval '1' year), date_trunc('year', CURRENT_TIMESTAMP), null, null, null),
    --   ('week',    date_trunc('year', CURRENT_TIMESTAMP - interval '1' year), date_trunc('year', CURRENT_TIMESTAMP), null, null, null),
    --   ('month',   date_trunc('year', CURRENT_TIMESTAMP - interval '1' year), date_trunc('year', CURRENT_TIMESTAMP), null, null, null)
    --   ('quarter', date_trunc('year', CURRENT_TIMESTAMP - interval '1' year), date_trunc('year', CURRENT_TIMESTAMP), null, null, null),
    --   ('year',    date_trunc('year', CURRENT_TIMESTAMP - interval '1' year), date_trunc('year', CURRENT_TIMESTAMP), null, null, null)
    ),
    cteDateRangeTypeAliases("Normal", "Alias") as (values
        ('year', 'yy'), ('year', 'years'), ('year', 'year'),
        ('quarter', 'qtr'), ('quarter', 'quarter'), ('quarter', 'quarter'),
        ('month', 'mm'), ('month', 'months'), ('month', 'month'),
        ('day', 'dd'), ('day', 'days'), ('day', 'day'),
        ('week', 'wk'), ('week', 'weeks'), ('week', 'week'),
        ('hour', 'hh'), ('hour', 'hours'), ('hour', 'hour'),
        ('minute', 'mi'), ('minute', 'minutes'), ('minute', 'minute'),
        ('second', 'ss'), ('second', 'seconds'), ('second', 'second')
    ),
    cteDateRangeTypes("Name", "DateRangeInterval", "DateRangeFormat") as (values
        ('hour', (interval '1' hour), 'YYYY-MM-DD HH'),
        ('day', (interval '1' day), 'YYYY-MM-DD'),
        ('week', (interval '7' day), 'IYYY-"week"IW'),
        ('month', (interval '1' month), 'YYYY-MM Month'),
        ('quarter', (interval '3' month), 'YYYY-MM Month'),
        ('year', (interval '1' year), 'YYYY')
    ),
    cteParams2 as (
        select
            "ParamDateRangeType"::text,
            "ParamBeginTimestamp"::timestamptz,
            "ParamEndTimestamp"::timestamptz,
            coalesce("ParamOffset"::interval, interval '0' second) as "ParamOffset",
            date_trunc('year', "ParamBeginTimestamp"::timestamptz) as "ParamBeginYear",
            date_trunc('year', "ParamEndTimestamp"::timestamptz) as "ParamEndYear",
            cteDateRangeTypes."DateRangeInterval",
            coalesce(cteParams."DateRangeFormat", cteDateRangeTypes."DateRangeFormat") as "DateRangeFormat"
        from cteParams
        inner join cteDateRangeTypeAliases on cteDateRangeTypeAliases."Alias" = cteParams."ParamDateRangeType"
        inner join cteDateRangeTypes on cteDateRangeTypes."Name" = cteDateRangeTypeAliases."Normal"
    ),
    cteParams3 as (
        select *,
            floor("public"."datediff"("ParamDateRangeType", "ParamBeginYear", "ParamBeginTimestamp")) as "YearBeginSkipIntervals",
            floor("public"."datediff"("ParamDateRangeType", "ParamEndYear", "ParamEndTimestamp")) as "YearEndIntervals"
        from cteParams2
    ),
    cteParams4 as (
        select
            "ParamBeginYear" + ("YearBeginSkipIntervals" * "DateRangeInterval") + "ParamOffset" as "GridBegin",
            "ParamEndYear" + ("YearEndIntervals" * "DateRangeInterval") + "ParamOffset" as "GridEnd",
            cteParams3.*
        from cteParams3
    ),
    cteParams5 as (
        select
            ceil(datediff("ParamDateRangeType", "GridBegin", "GridEnd"))::int4 as "GridIntervals",
            cteParams4.*
        from cteParams4
    ),
    cteDateRanges1 as (
        select
            "GridBegin" + ("DateRangeInterval" * generate_series(0,"GridIntervals")) as "DateRangeBegin",
            cteParams5.*
        from cteParams5
    )
    select
        to_char("DateRangeBegin", "DateRangeFormat") as dateRangeLabel,
        "DateRangeBegin" timestamptz,
         "DateRangeBegin" + "DateRangeInterval" as dateRangeEnd
    from cteDateRanges1;
end;
$$ language plpgsql;


-- Example
select dateRangeLabel, dateRangeBegin, dateRangeEnd
from dategrid(
    "part" := 'month',
    "beg" :=  CURRENT_TIMESTAMP - interval '1' year,
    "end" := CURRENT_TIMESTAMP,
    "offset" := null,
    "format" := null
);
