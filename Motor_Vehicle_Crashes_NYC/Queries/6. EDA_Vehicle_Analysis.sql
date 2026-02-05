-- 1. Vehicle types in crashes --

select 
	`VEHICLE TYPE CODE 1 CLEAN` as Vehicle_Type,
    count(*) Crash_Count,
    sum(`NUMBER OF PERSONS INJURED`) as Persons_Injured
from vehicle_collisions_staging
group by 1
order by 2 desc;

-- 2. Vehicle severity analysis--

select
	`VEHICLE TYPE CODE 1 CLEAN` as Vehicle_Type,
    count(*) Total_Crashes,
    sum(`NUMBER OF PERSONS INJURED`) Total_Persons_Injured,
    sum(`NUMBER OF PERSONS KILLED`) Total_Persons_Killed,
    round(avg(`NUMBER OF PERSONS INJURED`),0) Avg_Persons_Injured_Per_Crash,
    round(avg(`NUMBER OF PERSONS KILLED`),0) Avg_Person_Killed_Per_Crash
from vehicle_collisions_staging
where `VEHICLE TYPE CODE 1 CLEAN` is not null
group by 1
order by 2 desc;
