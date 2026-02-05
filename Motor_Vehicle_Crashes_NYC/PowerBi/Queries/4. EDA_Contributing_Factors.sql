-- 1. Top Contributing Factors --

select
	`CONTRIBUTING FACTOR VEHICLE 1` as Factor,
    count(*) as Occurence_Number
from vehicle_collisions_staging
group by 1
order by 2 desc
limit 5;

-- 2. Borough Vs Contributing Factor --
select 
	`BOROUGH`,
    `CONTRIBUTING FACTOR VEHICLE 1` as Factor,
    count(*) as Count
from vehicle_collisions_staging
where `CONTRIBUTING FACTOR VEHICLE 1` is not null
and `BOROUGH` is not null
group by 1,2
order by 3 desc;
