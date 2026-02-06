-- BUSINESS HEALTH AND SURVIVAL ANALYSIS --

select *
from business_licenses_staging
limit 10;

-- 1. License Duration Analysis --

select
	'License Duration' as Category,
	round(avg(datediff(`LICENSE TERM EXPIRATION DATE`,`LICENSE TERM START DATE`)),1) as Avg_Duration_Days,
    round(avg(datediff(`LICENSE TERM EXPIRATION DATE`,`LICENSE TERM START DATE`))/365,1) as Avg_Duration_Yrs
from business_licenses_staging
where `LICENSE TERM EXPIRATION DATE` is not null
and `LICENSE TERM START DATE` is not null;

-- 2. Renewal and Expiry Analysis --

with License_Lifecycle as
	(
    select 
    `LEGAL NAME`,
    `LICENSE STATUS`,
    `LICENSE TERM START DATE`,
    `LICENSE TERM EXPIRATION DATE`,
		case 
			when `LICENSE STATUS`in ('AAI','AAC') then 'Active'
			when `LICENSE STATUS`in ('REV','INQ') then 'Terminated'
            else 'Other'
		end as Status_Category
	from business_licenses_staging
    )
select 
	Status_Category,
    count(*) as Count,
    round( count(*) * 100 /sum( count(*)) over(),2) as Pct
from License_Lifecycle
group by 1;

-- 3. Businesses with multiple licenses ---

create temporary table Temp_counts 
(
    `LEGAL NAME` varchar(255), 
     Total_Licenses int
);

insert into Temp_counts
select `LEGAL NAME`,count(*)
from business_licenses_staging
where id between 1000001 and 2000000
group by 1;

select 
    License_Count_Range,
    count(*) as Businesses,
    sum(Total_Licenses) as Total_Licenses_in_Range
from (
    select *,
        case
            when Total_Licenses = 1 then 'Single License'
            when Total_Licenses between 2 and 4 then '2-4 Licenses'
            when Total_Licenses between 5 and 9 then '5-9 Licenses'
            else '10 plus Licenses'
        end as License_Count_Range
    from Temp_Counts
) t
group by License_Count_Range
order by field(License_Count_Range,'Single License','2-4 Licenses','5-9 Licenses','10 plus Licenses');



