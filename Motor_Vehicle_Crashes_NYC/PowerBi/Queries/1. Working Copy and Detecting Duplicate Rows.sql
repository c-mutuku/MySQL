-- 1. Check original table count--
select count(*)
from vehicle_collisions;

-- 2. Create staging table --
create table vehicle_collisions_staging
like vehicle_collisions;

-- 3. Insert data in batches --
insert into vehicle_collisions_staging
(
	`CRASH DATE`,
    `CRASH TIME`,
    `BOROUGH`,
    `ZIP CODE`,
    `LATITUDE`,
    `LONGITUDE`,
    `LOCATION`,
    `ON STREET NAME`,
    `CROSS STREET NAME`,
    `OFF STREET NAME`,
    `NUMBER OF PERSONS INJURED`,
    `NUMBER OF PERSONS KILLED`,
    `NUMBER OF PEDESTRIANS INJURED`,
    `NUMBER OF PEDESTRIANS KILLED`,
    `NUMBER OF CYCLIST INJURED`,
    `NUMBER OF CYCLIST KILLED`,
    `NUMBER OF MOTORIST INJURED`,
    `NUMBER OF MOTORIST KILLED`,
    `CONTRIBUTING FACTOR VEHICLE 1`,
    `CONTRIBUTING FACTOR VEHICLE 2`,
    `CONTRIBUTING FACTOR VEHICLE 3`,
    `CONTRIBUTING FACTOR VEHICLE 4`,
    `CONTRIBUTING FACTOR VEHICLE 5`,
    `COLLISION_ID`,
    `VEHICLE TYPE CODE 1`,
    `VEHICLE TYPE CODE 2`,
    `VEHICLE TYPE CODE 3`,
    `VEHICLE TYPE CODE 4`,
    `VEHICLE TYPE CODE 5`
)
select 
	`CRASH DATE`,
    `CRASH TIME`,
    `BOROUGH`,
    `ZIP CODE`,
    `LATITUDE`,
    `LONGITUDE`,
    `LOCATION`,
    `ON STREET NAME`,
    `CROSS STREET NAME`,
    `OFF STREET NAME`,
    `NUMBER OF PERSONS INJURED`,
    `NUMBER OF PERSONS KILLED`,
    `NUMBER OF PEDESTRIANS INJURED`,
    `NUMBER OF PEDESTRIANS KILLED`,
    `NUMBER OF CYCLIST INJURED`,
    `NUMBER OF CYCLIST KILLED`,
    `NUMBER OF MOTORIST INJURED`,
    `NUMBER OF MOTORIST KILLED`,
    `CONTRIBUTING FACTOR VEHICLE 1`,
    `CONTRIBUTING FACTOR VEHICLE 2`,
    `CONTRIBUTING FACTOR VEHICLE 3`,
    `CONTRIBUTING FACTOR VEHICLE 4`,
    `CONTRIBUTING FACTOR VEHICLE 5`,
    `COLLISION_ID`,
    `VEHICLE TYPE CODE 1`,
    `VEHICLE TYPE CODE 2`,
    `VEHICLE TYPE CODE 3`,
    `VEHICLE TYPE CODE 4`,
    `VEHICLE TYPE CODE 5`
from vehicle_collisions
limit 0,100000;

-- 4. Check staging table count --
select count(*)
from vehicle_collisions_staging;

-- 5. Check for duplicate rows--
select 
	count(*) as duplicate_group,
    sum(dup_count -1) as total_duplicate_rows
from
(
select 
	`CRASH DATE`,
    `CRASH TIME`,
    `BOROUGH`,
    `ZIP CODE`,
    `LATITUDE`,
    `LONGITUDE`,
    `LOCATION`,
    `ON STREET NAME`,
    `CROSS STREET NAME`,
    `OFF STREET NAME`,
     `COLLISION_ID`,
    count(*) as dup_count
from vehicle_collisions_staging
group by 
	`CRASH DATE`,
    `CRASH TIME`,
    `BOROUGH`,
    `ZIP CODE`,
    `LATITUDE`,
    `LONGITUDE`,
    `LOCATION`,
    `ON STREET NAME`,
    `CROSS STREET NAME`,
    `OFF STREET NAME`,
	`COLLISION_ID`
having dup_count > 1
) duplicates;


