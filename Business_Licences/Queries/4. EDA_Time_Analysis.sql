-- TEMPORAL ANALSYIS --

-- 1. Annual Trend--

select 
	year (`APPLICATION CREATED DATE`) as Yr,
	count(*) as Applications,
	lag(count(*)) over (order by year(`APPLICATION CREATED DATE`)) as Prev_Yr,
	round((count(*) - lag(count(*)) over (order by year(`APPLICATION CREATED DATE`))) * 100 /
		lag(count(*)) over (order by year(`APPLICATION CREATED DATE`)), 2) as Yoy_Growth_Pct
from business_licenses_staging
where `APPLICATION CREATED DATE` is not null
group by 1
order by Yr;
            
-- 2. Monthly Trends--
select 
    Monthname(`APPLICATION CREATED DATE`) as Month,
    count(*) as Applications,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as Pct_Of_Total
from business_licenses_staging
where `APPLICATION CREATED DATE` is not null
group by Month(`APPLICATION CREATED DATE`), Monthname(`APPLICATION CREATED DATE`)
order by Month(`APPLICATION CREATED DATE`);

-- 3. Processing Time Analysis --
/*
 DATA QUALITY NOTE --
Found 5 records where `DATE ISSUED` <`APPLICATION CREATED DATE`(impossible)
These are excluded in processing time analyis for accuracy
*/
select 
	'Processing Time Metrics' as Metric,
     round(avg(datediff(`DATE ISSUED`, `APPLICATION CREATED DATE`)), 1) as Avg_Days,  
     min(datediff(`DATE ISSUED`, `APPLICATION CREATED DATE`)) as Min_Days,
     max(datediff(`DATE ISSUED`, `APPLICATION CREATED DATE`)) as Max_Days,
     round(stddev(datediff(`DATE ISSUED`, `APPLICATION CREATED DATE`)), 1) as Std_Dev
from business_licenses_staging
where `DATE ISSUED` is not null
and `APPLICATION CREATED DATE` is not null
and  `DATE ISSUED`>`APPLICATION CREATED DATE`;

select *
from business_licenses_staging
where `DATE ISSUED` <`APPLICATION CREATED DATE`;


