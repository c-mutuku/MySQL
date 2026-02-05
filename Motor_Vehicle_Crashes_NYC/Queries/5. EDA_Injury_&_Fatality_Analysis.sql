-- 1. Injury and Fatality by Borough --

select 
	`BOROUGH`,
    sum(`NUMBER OF PERSONS INJURED`) as Persons_Injured,
    sum(`NUMBER OF PERSONS KILLED`) as Persons_Killed,
    round(sum(`NUMBER OF PERSONS KILLED`) * 100/ sum(`NUMBER OF PERSONS INJURED`),1) as Fatality_Rate
from vehicle_collisions_staging
where `BOROUGH` is not null
group by 1
order by 2 desc;

-- 2. Victim Type Analysis --

select
	`BOROUGH`,
    sum( `NUMBER OF PERSONS INJURED`) Persons_Injured,
    sum(`NUMBER OF PEDESTRIANS INJURED`) Pedestrians_Injured,
    sum(`NUMBER OF CYCLIST INJURED`) Cyclists_Injured
from vehicle_collisions_staging
where `BOROUGH` is not null
group by 1
order by 2 desc;