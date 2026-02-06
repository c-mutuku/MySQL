-- 1. Date Standardisation --

-- Check Date Columns --

select
 `APPLICATION CREATED DATE`,
 `APPLICATION REQUIREMENTS COMPLETE`,
 `PAYMENT DATE`,
 `LICENSE TERM START DATE`,
 `LICENSE TERM EXPIRATION DATE`,
 `LICENSE APPROVED FOR ISSUANCE`,
 `DATE ISSUED`,
 `LICENSE STATUS CHANGE DATE`
from business_licenses_staging
limit 100;

-- Set empty strings for all date columns as null--

update business_licenses_staging
set 
    `APPLICATION CREATED DATE` = nullif(trim(`APPLICATION CREATED DATE`), ''),
    `APPLICATION REQUIREMENTS COMPLETE` = nullif(trim(`APPLICATION REQUIREMENTS COMPLETE`), ''),
    `PAYMENT DATE` = nullif(trim(`PAYMENT DATE`), ''),
    `LICENSE TERM START DATE` = nullif(trim(`LICENSE TERM START DATE`), ''),
    `LICENSE TERM EXPIRATION DATE` = nullif(trim(`LICENSE TERM EXPIRATION DATE`), ''),
    `LICENSE APPROVED FOR ISSUANCE` = nullif(trim(`LICENSE APPROVED FOR ISSUANCE`), ''),
    `DATE ISSUED` = nullif(trim(`DATE ISSUED`), ''),
    `LICENSE STATUS CHANGE DATE` = nullif(trim(`LICENSE STATUS CHANGE DATE`), '');

 -- Convert string dates to date data type --

alter table business_licenses_staging
modify column `APPLICATION CREATED DATE` date;

alter table business_licenses_staging  
modify column `APPLICATION REQUIREMENTS COMPLETE` date ;

alter table business_licenses_staging
modify column `PAYMENT DATE` date ;

alter table business_licenses_staging
modify column `LICENSE TERM START DATE` date;

alter table business_licenses_staging
modify column `LICENSE TERM EXPIRATION DATE` date;

alter table business_licenses_staging
modify column `LICENSE APPROVED FOR ISSUANCE` date;

alter table business_licenses_staging
modify column `DATE ISSUED` date ;

alter table business_licenses_staging
modify column  `LICENSE STATUS CHANGE DATE` date;

-- 2. Data Standardisation --

select * 
from business_licenses_staging
limit 100;

-- Text Cleaning --

select `ID`
from business_licenses_staging
where `ID` like '  '
or `ID` like ' %'
or `ID` like '% ';

select `LICENSE ID`
from business_licenses_staging
where `LICENSE ID` like '  '
or `LICENSE ID` like ' %'
or `LICENSE ID` like '% ';

select `ACCOUNT NUMBER`
from business_licenses_staging
where `ACCOUNT NUMBER` like '  '
or `ACCOUNT NUMBER` like ' %'
or `ACCOUNT NUMBER` like '% ';

select `SITE NUMBER`
from business_licenses_staging
where `SITE NUMBER` like '  '
or `SITE NUMBER` like ' %'
or `SITE NUMBER` like '% ';
 
select distinct `LEGAL NAME`
from business_licenses_staging
order by 1;

 select distinct `LEGAL NAME`, upper(trim(
	replace(
		trim(trailing ',' from
        trim(trailing '.' from  `LEGAL NAME`)),
        '  ',' ')
        )) as clean
from business_licenses_staging 
order by 1 ;
 
 update business_licenses_staging
 set `LEGAL NAME`= upper(trim(
	replace(
		trim(trailing ',' from
        trim(trailing '.' from  `LEGAL NAME`)),
        '  ',' ')
        ));

/*
-- Legal name cleaning - Suffix Standardisation ---
Purpose: Standardize legal suffixes to improve analysis
*/

update business_licenses_staging
set `LEGAL NAME` = upper(trim(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
	replace(
    replace(
	replace(`LEGAL NAME`,
		'INCORPORATED','INC'),
        'INC.','INC'),
        'CORPORATION','CORP'),
        'CORPORATION.','CORP'),
        'CORP.','CORP'),
        'EXCHANGE','EX'),
        'EXCHA','EX'),
        'EXCH.','EX'),
        'COMPANY','CO'),
        'CO.','CO'),
        'L.L.C','LLC'),
        'LIMITED LIABILITY COMPANY','LLC'),
        'LIMITED','LTD'),
        'CURR','CUR'),
        'CURENCY','CUR'),
        'CUR.','CUR'))
        ); 
 
select distinct `ADDRESS`
from business_licenses
order by 1;

select distinct `ADDRESS` , upper(trim(
    replace(
	trim(both from
    trim(trailing ',' from
    trim(both  '.' from
	trim(both '/' from 
    trim(leading '-' from 
	trim(trailing '#' from `ADDRESS`)))))),
	'  ',' '))) as clean
from  business_licenses_staging
order by 1;
 
update business_licenses_staging
set `ADDRESS`= upper(trim(
    replace(
	trim(both from
    trim(trailing ',' from
    trim(both  '.' from
	trim(both '/' from 
    trim(leading '-' from 
	trim(trailing '#' from `ADDRESS`)))))),
	'  ',' ')));
    
 /*
--Adresses cleaning - Suffix Standardisation ---
Purpose: Standardize street suffixes to improve geocoding match rates
*/

/*
-- Address suffix standardization process:
1. Created mapping table after analyzing raw data for common suffix variations.
2. Populated with raw-to-clean pairs from Excel to handle inconsistencies (e.g., 'AVE', 'AV', 'AVE.' -> 'AVENUE').
3. Discovered initial SQL joins missed many variations, requiring iterative updates to the mapping.
4. Added new suffix entries incrementally to close coverage gaps (e.g., NYC-specific 'AVE S', 'FDR DR').
5. Final mapping ensures consistent address matching and reliable geocoding.
*/

create table street_suffix_mapping(
	raw_name varchar(100) primary key,
    clean_name varchar(100)); 
 
 -- Check Mapping Table --
 
select *
from street_suffix_mapping;

 -- Update table with standardised suffixes--

select
	l.`ADDRESS` as OG_Name,
    concat(trim(substring(l.`ADDRESS`,1,length(l.`ADDRESS`)-length(s.`raw_name`))),
	' ',s.`clean_name`) as Corrected
from business_licenses_staging l
join street_suffix_mapping s
	on lower(l.`ADDRESS`) like concat('% ',s.`raw_name`)
limit 20;

update business_licenses_staging l
join street_suffix_mapping s
	on (l.`ADDRESS`) like concat('% ',s.`raw_name`)
set l.`ADDRESS`= concat(trim(substring(l.`ADDRESS`,1,length(l.`ADDRESS`)-length(s.`raw_name`))),
	' ',s.`clean_name`)
where l.`ADDRESS` like concat('% ',s.`raw_name`);

select distinct  `CITY`
from business_licenses_staging
order by 1; 

update business_licenses_staging
set `CITY` = replace(trim(upper(`CITY`)),'  ',' ');

update business_licenses_staging
set `CITY`=null
where trim(`CITY`) = ''
or length(trim(`CITY`)) <2;

select
 count(distinct `CITY`) as unique_cities,
 count(*) as total_rows
from business_licenses_staging;

 select `CITY`, count(*) as record_count
 from business_licenses_staging
 group by 1
 order by 2 desc
 limit 10;
 
 -- Check for city names that sound similar--
 
select `CITY`,
	count(*) as cnt,
	soundex(`CITY`) as sound,
	row_number() over (partition by soundex(`CITY`) order by `CITY`) as rn
from business_licenses_staging
group by `CITY`,soundex(`CITY`)
order by 3,1 ;

with city_duplicates as 
	(
    select `CITY`,
		count(*) as cnt,
		soundex(`CITY`) as sound,
		row_number() over (partition by soundex(`CITY`) order by `CITY`) as ROW_NUM
	from business_licenses_staging
	group by `CITY`,soundex(`CITY`)
	order by 3,1 
	)
select *
from city_duplicates
where ROW_NUM >1;

-- Create mapping table to standardise city names--

create table city_mapping (
	raw_city varchar(50) primary key,
    clean_city varchar(50));

insert into city_mapping (raw_city,clean_city)
values
('ARLINGTON HEIGTHS','ARLINGTON HEIGHTS'),
('ARLINGTONHEIGHTS','ARLINGTON HEIGHTS'),
('ARLINGTON HTS.','ARLINGTON HEIGHTS'),
('CHICAGO','CHICAGO'),
('CHCAGO','CHICAGO'),
('CHCIAGO','CHICAGO'),
('CHIACGO','CHICAGO'),
('CHIAGO','CHICAGO'),
('CHIC','CHICAGO'),
('CHIC AGO','CHICAGO'),
('CHICAGO,','CHICAGO'),
('CHICAGOO','CHICAGO'),
('CHICAO','CHICAGO'),
('CHIICAGO','CHICAGO'),
('CHICATO','CHICAGO'),
('CHIDAGO','CHICAGO'),
('SKOKI','SKOKIE'),
('NORHTBROOK','NORTHBROOK'),
('DESPLAINES','DES PLAINES'),
('DES PLANIES','DES PLAINES'),
('DESPLANES','DES PLAINES'),
('DES PLAINS','DES PLAINES'),
('ELK GROVE VLG','ELK GROVE'),
('ELK','ELK GROVE'),
('ELK GROVE VILLAGE','ELK GROVE'),
('ELK GROVE VILLIGE','ELK GROVE'),
('ELK GROVE VILLAGEVILLAA','ELK GROVE'),
('NILE','NILES'),
('OAKPARK','OAK PARK'),
('OAK OARK','OAK PARK');

select *
from city_mapping ;

update business_licenses_staging l
join city_mapping c
	on l.`CITY`=c.`raw_city`
set l.`CITY`=c.`clean_city`;

-- Set empty rows as null ---

UPDATE business_licenses_staging
SET
    `ID` = NULLIF(TRIM(`ID`), ''),
    `LICENSE ID` = NULLIF(TRIM(`LICENSE ID`), ''),
    `STATE` = NULLIF(UPPER(TRIM(`STATE`)), ''),
    `ADDRESS` = NULLIF(TRIM(`ADDRESS`), ''),
    `WARD` = NULLIF(TRIM(`WARD`), ''),
    `PRECINCT` = NULLIF(TRIM(`PRECINCT`), ''),
    `WARD PRECINCT` = NULLIF(TRIM(`WARD PRECINCT`), ''),
    `POLICE DISTRICT` = NULLIF(TRIM(`POLICE DISTRICT`), ''),
    `COMMUNITY AREA` = NULLIF(TRIM(`COMMUNITY AREA`), ''),
    `COMMUNITY AREA NAME` = NULLIF(UPPER(TRIM(`COMMUNITY AREA NAME`)), ''),
    `NEIGHBORHOOD` = NULLIF(UPPER(TRIM(`NEIGHBORHOOD`)), ''),
    `LICENSE DESCRIPTION` = NULLIF(UPPER(TRIM(`LICENSE DESCRIPTION`)), ''),
    `APPLICATION TYPE` = NULLIF(UPPER(TRIM(`APPLICATION TYPE`)), ''),
    `CONDITIONAL APPROVAL` = NULLIF(UPPER(TRIM(`CONDITIONAL APPROVAL`)), ''),
    `LICENSE STATUS` = NULLIF(UPPER(TRIM(`LICENSE STATUS`)), ''),
    `SSA` = NULLIF(TRIM(`SSA`), ''),
    `LATITUDE` = NULLIF(TRIM(`LATITUDE`), ''),
    `LONGITUDE` = NULLIF(TRIM(`LONGITUDE`), ''),
    `LOCATION` = NULLIF(TRIM(`LOCATION`), '');
