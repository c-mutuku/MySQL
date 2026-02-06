-- BASIC DESCRIPTIVE ANALYSIS --

-- 1. Volume Metrics--

select count(*) as Total_Businesses,
	   count(distinct `LEGAL NAME`) as Unique_Businesses,
       count(distinct `LICENSE DESCRIPTION`) as Business_Type,
       count(distinct `CITY`) as Cities_Represented
from business_licenses_staging;

-- 2. License Distribution--

select `LICENSE DESCRIPTION`,
		count(*) as License_Count,
        round(count(*)*100/sum(count(*)) over(),2) as Pct_of_total
from business_licenses_staging
group by 1
order by 2 desc
limit 20;

-- 3. Status Breakdown--

select `LICENSE STATUS`,
		count(*) as Status_Count,
        round(count(*)*100/sum(count(*)) over(),2) as Pct_of_Total
from business_licenses_staging
group by 1
order by 2 desc
limit 20;

