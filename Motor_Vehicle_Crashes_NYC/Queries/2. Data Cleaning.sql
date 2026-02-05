-- 1. Date and Time Standardisation --

-- Check Date and Time Columns --

select 
	`CRASH DATE`,
    `CRASH TIME`
from vehicle_collisions_staging
limit 100;

-- Set empty strings for Date and Time columns as null--

update vehicle_collisions_staging
set 
	`CRASH DATE`=nullif(trim(`CRASH DATE`),''),
    `CRASH TIME`=nullif(trim(`CRASH TIME`),'');

-- Convert string dates and time to date and time format--

select 
	`CRASH DATE`,
    str_to_date(`CRASH DATE`,'%m/%d/%Y')
from vehicle_collisions_staging
limit 1000;

update vehicle_collisions_staging
set `CRASH DATE` =  str_to_date(`CRASH DATE`,'%m/%d/%Y');

select 
	`CRASH TIME`,
    str_to_date(`CRASH TIME`,'%H:%i')
from vehicle_collisions_staging
limit 1000;

update vehicle_collisions_staging
set `CRASH TIME`= str_to_date(`CRASH TIME`,'%H:%i');

-- Checking for failed conversions--

select
	count(*) as Total_Rows,
    count(`CRASH DATE`) as Valid_Date_Rows
from vehicle_collisions_staging;

select
	count(*) as Total_Rows,
    count(`CRASH TIME`) as Valid_Time_Rows
from vehicle_collisions_staging;

-- Convert strings to date and time data type--

alter table vehicle_collisions_staging
modify column `CRASH DATE` date;

alter table vehicle_collisions_staging
modify column `CRASH TIME` time;

-- 2. Data Standardisation --

select *
from vehicle_collisions_staging
limit 1000;

-- Text Cleaning --

select distinct `BOROUGH`
from vehicle_collisions_staging
order by 1 asc;

select distinct `ZIP CODE`
from vehicle_collisions_staging
order by 1 asc;

select distinct `LATITUDE`
from vehicle_collisions_staging
order by 1 asc;

select distinct `LONGITUDE`
from vehicle_collisions_staging
order by 1 asc;

select distinct `LOCATION`
from vehicle_collisions_staging
order by 1 asc;
    
update vehicle_collisions_staging
set 
   `BOROUGH`= upper(trim(`BOROUGH`)),
   `ZIP CODE`= trim(`ZIP CODE`),
   `LATITUDE`=  trim(`LATITUDE`),
   `LONGITUDE`=  trim(`LONGITUDE`),
   `LOCATION`=  trim(`LOCATION`);
      
select distinct `ON STREET NAME`
from vehicle_collisions_staging
order by 1 asc;

select distinct `ON STREET NAME`, 
				trim(replace(
				upper(
					trim(trailing '.'from
                    trim(trailing '@' from
					trim(`ON STREET NAME`)))),
                    '  ',' ')) as Clean
from vehicle_collisions_staging
order by 1 asc;

update vehicle_collisions_staging
set  `ON STREET NAME`=
		trim(replace(
			upper(
				trim(trailing '.'from
				trim(trailing '@' from
				trim(`ON STREET NAME`)))),
				'  ',' '));
            
/*
-- Street name cleaning - Suffix Standardisation ---
Purpose: Standardize street suffixes to improve geocoding match rates
*/

/*
-- Street suffix standardization process:
1. Created mapping table after analyzing raw data for common suffix variations.
2. Populated with raw-to-clean pairs from Excel to handle inconsistencies (e.g., 'AVE', 'AV', 'AVE.' -> 'AVENUE').
3. Discovered initial SQL joins missed many variations, requiring iterative updates to the mapping.
4. Added new suffix entries incrementally to close coverage gaps (e.g., NYC-specific 'AVE S', 'FDR DR').
5. Final mapping ensures consistent address matching and reliable geocoding.
*/

create table suffix_mapping(
	raw_name varchar(100) primary key,
    clean_name varchar(100));
    
-- Check Mapping Table --

select *
from suffix_mapping;

-- Update table with standardised suffixes--

select
	v.`ON STREET NAME` as OG_Name,
    concat(trim(substring(v.`ON STREET NAME`,1,length(v.`ON STREET NAME`)-length(s.`raw_name`))),
	' ',s.`clean_name`) as Corrected
from vehicle_collisions_staging v
join suffix_mapping s
	on lower(v.`ON STREET NAME`) like concat('% ',s.`raw_name`)
limit 20;

update vehicle_collisions_staging v
join suffix_mapping s
	on (v.`ON STREET NAME`) like concat('% ',s.`raw_name`)
set v.`ON STREET NAME`= concat(trim(substring(v.`ON STREET NAME`,1,length(v.`ON STREET NAME`)-length(s.`raw_name`))),
	' ',s.`clean_name`)
where v.`ON STREET NAME` like concat('% ',s.`raw_name`);

-- Compare unique street names to total rows in the data ---

select 
		count(distinct(`ON STREET NAME`)) as Unique_Street,
        count(*) as Total_Rows
from vehicle_collisions_staging;
    
-- Top Street Names--

select
    `ON STREET NAME`,
    count(*) as Record_Count,
	round(count(*) * 100.0 / SUM(COUNT(*)) over(), 1) as Pct_Of_Total
from vehicle_collisions_staging 
where `ON STREET NAME` IS NOT NULL 
group by 1
order by 2 desc;
    
select distinct `CROSS STREET NAME`
from vehicle_collisions_staging
order by 1 asc;    
    
select distinct `CROSS STREET NAME`, upper(trim(
    replace(
    trim(trailing '.'from
    trim(leading '.' from
    trim(leading '?' from `CROSS STREET NAME`))),
    '  ',' '))) as Clean
from vehicle_collisions_staging
order by 1 asc;
    
update vehicle_collisions_staging
set `CROSS STREET NAME` =  upper(trim(
    replace(
    trim(trailing '.'from
    trim(leading '.' from
    trim(leading '?' from `CROSS STREET NAME`))),
    '  ',' ')));
    
-- Update table with the standardised suffixes-- 

select
	v.`CROSS STREET NAME` as OG_Name,
    concat(trim(substring(v.`CROSS STREET NAME`,1,length(v.`CROSS STREET NAME`)-length(s.`raw_name`))),
	' ',s.`clean_name`) as Corrected
from vehicle_collisions_staging v
join suffix_mapping s
	on lower(v.`CROSS STREET NAME`) like concat('% ',s.`raw_name`)
limit 20;

update vehicle_collisions_staging v
join suffix_mapping s
	on (v.`CROSS STREET NAME`) like concat('% ',s.`raw_name`)
set v.`CROSS STREET NAME`= concat(trim(substring(v.`CROSS STREET NAME`,1,length(v.`CROSS STREET NAME`)-length(s.`raw_name`))),
	' ',s.`clean_name`)
where v.`CROSS STREET NAME` like concat('% ',s.`raw_name`);  

select distinct `OFF STREET NAME`
from vehicle_collisions_staging
order by 1 asc;

select distinct `OFF STREET NAME`, upper(trim(
		replace(
		trim(leading ':' from
        trim(leading '*' from
        trim( trailing '.' from `OFF STREET NAME`))),
        '  ',' '))) as Clean
from vehicle_collisions_staging
order by 1 asc;

update vehicle_collisions_staging
set `OFF STREET NAME` = upper(trim(
		replace(
        trim(leading ':' from
        trim(trailing '.' from `OFF STREET NAME`)),
        '  ',' ')));

select
	v.`OFF STREET NAME` as OG_Name,
    concat(trim(substring(v.`OFF STREET NAME`,1,length(v.`OFF STREET NAME`)-length(s.`raw_name`))),
	' ',s.`clean_name`) as Corrected
from vehicle_collisions_staging v
join suffix_mapping s
	on lower(v.`OFF STREET NAME`) like concat('% ',s.`raw_name`)
limit 20;

update vehicle_collisions_staging v
join suffix_mapping s
	on (v.`OFF STREET NAME`) like concat('% ',s.`raw_name`)
set v.`OFF STREET NAME`= concat(trim(substring(v.`OFF STREET NAME`,1,length(v.`OFF STREET NAME`)-length(s.`raw_name`))),
	' ',s.`clean_name`)
where v.`OFF STREET NAME` like concat('% ',s.`raw_name`);  

select distinct `CONTRIBUTING FACTOR VEHICLE 1`
from vehicle_collisions_staging
order by 1 asc;

select distinct `CONTRIBUTING FACTOR VEHICLE 2`
from vehicle_collisions_staging
order by 1 asc;

select distinct  `CONTRIBUTING FACTOR VEHICLE 3`
from vehicle_collisions_staging
order by 1 asc;

select distinct  `CONTRIBUTING FACTOR VEHICLE 4`
from vehicle_collisions_staging
order by 1 asc;

select distinct `CONTRIBUTING FACTOR VEHICLE 5`
from vehicle_collisions_staging
order by 1 asc;

update vehicle_collisions_staging
set
	`CONTRIBUTING FACTOR VEHICLE 1`= upper(trim(`CONTRIBUTING FACTOR VEHICLE 1`)),
	`CONTRIBUTING FACTOR VEHICLE 2`= upper(trim(`CONTRIBUTING FACTOR VEHICLE 2`)),
	`CONTRIBUTING FACTOR VEHICLE 3`= upper(trim(`CONTRIBUTING FACTOR VEHICLE 3`)),
	`CONTRIBUTING FACTOR VEHICLE 4`= upper(trim(`CONTRIBUTING FACTOR VEHICLE 4`)),
	`CONTRIBUTING FACTOR VEHICLE 5`= upper(trim(`CONTRIBUTING FACTOR VEHICLE 5`));

select count(distinct `COLLISION_ID`)
from vehicle_collisions_staging
order by 1 asc;

select distinct `VEHICLE TYPE CODE 1`
from vehicle_collisions_staging
order by 1 asc;

select distinct `VEHICLE TYPE CODE 1`, upper(trim(
		replace(
        replace(
        trim(trailing '.' from
        trim(leading '.' from
        trim(leading '?' from `VEHICLE TYPE CODE 1`))),
        '  ',' '),
        '"',''))) as clean
from vehicle_collisions_staging
order by 1 asc;

update vehicle_collisions_staging
set  `VEHICLE TYPE CODE 1` = upper(trim(
		replace(
        replace(
        trim(trailing '.' from
        trim(leading '.' from
        trim(leading '?' from `VEHICLE TYPE CODE 1`))),
        '  ',' '),
        '"','')));

select distinct `VEHICLE TYPE CODE 2`
from vehicle_collisions_staging
order by 1 asc;

update vehicle_collisions_staging
set  `VEHICLE TYPE CODE 2` = upper(trim(
		replace(
        replace(
        trim(trailing '.' from
        trim(leading '.' from
        trim(leading '?' from `VEHICLE TYPE CODE 2`))),
        '  ',' '),
        '"','')));

select distinct `VEHICLE TYPE CODE 3`
from vehicle_collisions_staging
order by 1 asc;

update vehicle_collisions_staging
set  `VEHICLE TYPE CODE 3` = upper(trim(
		replace(
        replace(
        trim(trailing '.' from
        trim(leading '.' from
        trim(leading '?' from `VEHICLE TYPE CODE 3`))),
        '  ',' '),
        '"','')));

select distinct `VEHICLE TYPE CODE 4`
from vehicle_collisions_staging
order by 1 asc;

update vehicle_collisions_staging
set  `VEHICLE TYPE CODE 4` = upper(trim(
		replace(
        replace(
        trim(trailing '.' from
        trim(leading '.' from
        trim(leading '?' from `VEHICLE TYPE CODE 4`))),
        '  ',' '),
        '"','')));

select distinct `VEHICLE TYPE CODE 5`
from vehicle_collisions_staging
order by 1 asc;

update vehicle_collisions_staging
set  `VEHICLE TYPE CODE 5` = upper(trim(
		replace(
        replace(
        trim(trailing '.' from
        trim(leading '.' from
        trim(leading '?' from `VEHICLE TYPE CODE 5`))),
        '  ',' '),
        '"','')));

/*
Vehicle type classification and standardization process:
1. Created mapping table after analyzing thousands of raw vehicle type entries.
2. Populated with raw-to-clean pairs from Excel to categorize into standardized groups (e.g., 'SEDAN', '4D' -> 'PASSENGER CAR').
3. Discovered initial classification missed many variations, requiring iterative updates to expand coverage.
4. Added new vehicle type entries incrementally to ensure complete categorization (e.g., emergency vehicles like 'AMB', 'POL' -> 'AMBULANCE', 'POLICE').
5. Final mapping ensures consistent vehicle categorization for accurate accident analysis and reporting.
*/

create table vehicle_type_mapping(
	raw_name varchar(100) primary key,
    clean_name varchar(100));

select *
from vehicle_type_mapping;
     
alter table vehicle_collisions_staging    
add column `VEHICLE TYPE CODE 1 CLEAN` varchar(100),
add column `VEHICLE TYPE CODE 2 CLEAN` varchar(100),
add column `VEHICLE TYPE CODE 3 CLEAN` varchar(100),
add column `VEHICLE TYPE CODE 4 CLEAN` varchar(100),
add column `VEHICLE TYPE CODE 5 CLEAN` varchar(100);
    
update vehicle_collisions_staging v
left join vehicle_type_mapping m on v.`VEHICLE TYPE CODE 1` = m.`raw_name`
set v.`VEHICLE TYPE CODE 1 CLEAN`= ifnull(m.`clean_name`,'OTHER');
    
update vehicle_collisions_staging v
left join vehicle_type_mapping m on v.`VEHICLE TYPE CODE 2` = m.`raw_name`
set v.`VEHICLE TYPE CODE 2 CLEAN`= ifnull(m.`clean_name`,'OTHER');   
    
update vehicle_collisions_staging v
left join vehicle_type_mapping m on v.`VEHICLE TYPE CODE 3` = m.`raw_name`
set v.`VEHICLE TYPE CODE 3 CLEAN`= ifnull(m.`clean_name`,'OTHER');   

update vehicle_collisions_staging v
left join vehicle_type_mapping m on v.`VEHICLE TYPE CODE 4` = m.`raw_name`
set v.`VEHICLE TYPE CODE 4 CLEAN`= ifnull(m.`clean_name`,'OTHER');

update vehicle_collisions_staging v
left join vehicle_type_mapping m on v.`VEHICLE TYPE CODE 5` = m.`raw_name`
set v.`VEHICLE TYPE CODE 5 CLEAN`= ifnull(m.`clean_name`,'OTHER');

-- Change string data type to integer data type --

alter table vehicle_collisions_staging
modify column `NUMBER OF PERSONS INJURED` int;

alter table vehicle_collisions_staging
modify column `NUMBER OF PERSONS KILLED` int;

alter table vehicle_collisions_staging
modify column `NUMBER OF PEDESTRIANS INJURED` int;

alter table vehicle_collisions_staging
modify column `NUMBER OF PEDESTRIANS KILLED` int;

alter table vehicle_collisions_staging
modify column `NUMBER OF CYCLIST INJURED` int;

alter table vehicle_collisions_staging
modify column `NUMBER OF CYCLIST KILLED` int;

alter table vehicle_collisions_staging
modify column `NUMBER OF MOTORIST INJURED` int;

alter table vehicle_collisions_staging
modify column `NUMBER OF MOTORIST KILLED` int;

-- 3. Set empty rows as null--

update vehicle_collisions_staging
set
	 `BOROUGH`= nullif(upper(trim(`BOROUGH`)),''),
	 `ZIP CODE`= nullif(trim(`ZIP CODE`),''),
	 `LATITUDE`=  nullif(trim(`LATITUDE`),''),
	 `LONGITUDE`=  nullif(trim(`LONGITUDE`),''),
	 `LOCATION`=  nullif(trim(`LOCATION`),''),
	 `ON STREET NAME`= nullif(trim(`ON STREET NAME`),''),
	 `CROSS STREET NAME`= nullif(trim(`CROSS STREET NAME`),''),
	 `OFF STREET NAME`= nullif(trim(`OFF STREET NAME`),''),
	 `CONTRIBUTING FACTOR VEHICLE 1`  = nullif(trim(`CONTRIBUTING FACTOR VEHICLE 1`),''),
	 `CONTRIBUTING FACTOR VEHICLE 2`= nullif(trim(`CONTRIBUTING FACTOR VEHICLE 2`),''),
	 `CONTRIBUTING FACTOR VEHICLE 3`= nullif(trim(`CONTRIBUTING FACTOR VEHICLE 3`),''),
	 `CONTRIBUTING FACTOR VEHICLE 4`= nullif(trim(`CONTRIBUTING FACTOR VEHICLE 4`),''),
	 `CONTRIBUTING FACTOR VEHICLE 5`= nullif(trim(`CONTRIBUTING FACTOR VEHICLE 5`),''),
	 `COLLISION_ID`= nullif(trim(`COLLISION_ID`),''),
	 `VEHICLE TYPE CODE 1`= nullif(trim(  `VEHICLE TYPE CODE 1`),''),
	 `VEHICLE TYPE CODE 2`= nullif(trim(`VEHICLE TYPE CODE 2`),''),
	 `VEHICLE TYPE CODE 3`= nullif(trim(`VEHICLE TYPE CODE 3`),''),
	 `VEHICLE TYPE CODE 4`= nullif(trim(`VEHICLE TYPE CODE 4`),''),  
	 `VEHICLE TYPE CODE 5`= nullif(trim( `VEHICLE TYPE CODE 5`),'');  
    
    
    

    
    
   
    
    
  
    
    
    
   