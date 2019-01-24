----------------------------------------------------------------------------
-- This SQL script is used to demo how the Python Library SQL Runner works
----------------------------------------------------------------------------


drop external table if exists demo_countries_load;
create readable external temp table demo_countries_load
(
  country_name varchar,
  country_code varchar
) 
 location
(
  'gpfdist://csor2gpl04-1:8081/wecheng/Demo/demo_input_@CALENDAR_MONTH.txt'
)
FORMAT 'text' (delimiter E'\t' null 'null' escape 'off') ENCODING 'LATIN9';

drop table if exists demo_countries;
create temp table demo_countries as(
select *
from demo_countries_load
group by 1,2
)distributed by (country_name);


drop table if exists public.demo_country_table_@CALENDAR_MONTH_@VERSION;
create table public.demo_country_table_@CALENDAR_MONTH_@VERSION as(
select @CALENDAR_MONTH::varchar as calendar_month, b.country_name, b.country_code
from public.country_lookup a
right join demo_countries b
on a.country_name = b.country_name
group by 1,2,3
)distributed by (country_name);

grant all on public.demo_country_table_@CALENDAR_MONTH_@VERSION to public;




drop external table if exists demo_output;
create writable external temp table demo_output
(
      country_name varchar,
      country_code varchar,
      calendar_month varchar
)
location
(
'gpfdist://csor2gpl04-1:8081/wecheng/Demo/demo_out_@CALENDAR_MONTH.txt'
)
format 'text' (delimiter E'\t' null 'null' escape 'off')
encoding 'UTF8'
;

insert into demo_output
select *
from public.demo_country_table_@CALENDAR_MONTH_@VERSION
group by  1,2,3;
