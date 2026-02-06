-- GEOGRAPHICAL ANALYSIS --

-- 1.Top Cities By Business Count --
select 
	`CITY`,
    count(*) as Business_Count,
    round(count(*)*100 / sum(count(*)) over (), 2) as Market_Share_Pct,
	row_number () over (order by count(*) desc) as 'Rank'
from business_licenses_staging
where `CITY` is not null
group by 1
order by 2 desc
limit 20;

-- 2. Business Density by Ward --
select 
	`WARD`,
    count(*) as Licenses,
    count(distinct `CITY`) as Cities_in_Wards,
    round(count(*) *100 / sum(count(*)) over(),2) as Pct_Of_Total
from business_licenses_staging
where `WARD` is not null
group by 1
order by 2 desc
limit 20;

-- 3. License Type by Geography--
select 
	`CITY`,
    `LICENSE DESCRIPTION`,
    count(*) as Total_Licenses
from business_licenses_staging
where `CITY` is not null
group by 1,2
order by 3 desc
limit 20;