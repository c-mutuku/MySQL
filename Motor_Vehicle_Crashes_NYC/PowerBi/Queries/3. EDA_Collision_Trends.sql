-- 1. Yearly Trend --

select 
	year(`CRASH DATE`) as Crash_Year,
    count(*) as Total_Crashes
from vehicle_collisions_staging
group by 1
order by 1 asc;

-- 2. Borough Crash Rates --

select
	`BOROUGH`,
    count(*) as Crash_Count,
    round(count(*) * 100/sum(count(*))over(),1) as Percentage
from vehicle_collisions_staging
where `BOROUGH` is not null
group by 1
order by 2 desc;


-- 3. Time Analysis --

select 
	 hour(`CRASH TIME`) Hour,
	 count(*) as Crash_Count
from vehicle_collisions_staging
where `CRASH TIME` is not null
group by 1
order by 2;
