-- 1. Check original table count--
select count(*)
from business_licenses;

-- 2. Create staging table --
create table business_licenses_staging 
like business_licenses;

-- 3. Insert data in batches --
insert into business_licenses_staging
(
    `ID`,
    `LICENSE ID`,
    `ACCOUNT NUMBER`,
    `SITE NUMBER`,
    `LEGAL NAME`,
    `DOING BUSINESS AS NAME`,
    `ADDRESS`,
    `CITY`,
    `STATE`,
    `ZIP CODE`,
    `WARD`,
    `PRECINCT`,
    `WARD PRECINCT`,
    `POLICE DISTRICT`,
    `COMMUNITY AREA`,
    `COMMUNITY AREA NAME`,
    `NEIGHBORHOOD`,
    `LICENSE CODE`,
    `LICENSE DESCRIPTION`,
    `BUSINESS ACTIVITY ID`,
    `BUSINESS ACTIVITY`,
    `LICENSE NUMBER`,
    `APPLICATION TYPE`,
    `APPLICATION CREATED DATE`,
    `APPLICATION REQUIREMENTS COMPLETE`,
    `PAYMENT DATE`,
    `CONDITIONAL APPROVAL`,
    `LICENSE TERM START DATE`,
    `LICENSE TERM EXPIRATION DATE`,
    `LICENSE APPROVED FOR ISSUANCE`,
    `DATE ISSUED`,
    `LICENSE STATUS`,
    `LICENSE STATUS CHANGE DATE`,
    `SSA`,
    `LATITUDE`,
    `LONGITUDE`,
    `LOCATION`
)
select
    `ID`,
    `LICENSE ID`,
    `ACCOUNT NUMBER`,
    `SITE NUMBER`,
    `LEGAL NAME`,
    `DOING BUSINESS AS NAME`,
    `ADDRESS`,
    `CITY`,
    `STATE`,
    `ZIP CODE`,
    `WARD`,
    `PRECINCT`,
    `WARD PRECINCT`,
    `POLICE DISTRICT`,
    `COMMUNITY AREA`,
    `COMMUNITY AREA NAME`,
    `NEIGHBORHOOD`,
    `LICENSE CODE`,
    `LICENSE DESCRIPTION`,
    `BUSINESS ACTIVITY ID`,
    `BUSINESS ACTIVITY`,
    `LICENSE NUMBER`,
    `APPLICATION TYPE`,
    `APPLICATION CREATED DATE`,
    `APPLICATION REQUIREMENTS COMPLETE`,
    `PAYMENT DATE`,
    `CONDITIONAL APPROVAL`,
    `LICENSE TERM START DATE`,
    `LICENSE TERM EXPIRATION DATE`,
    `LICENSE APPROVED FOR ISSUANCE`,
    `DATE ISSUED`,
    `LICENSE STATUS`,
    `LICENSE STATUS CHANGE DATE`,
    `SSA`,
    `LATITUDE`,
    `LONGITUDE`,
    `LOCATION`
FROM business_licenses
LIMIT 1100000, 100000;

-- 4. Check staging table count --
select count(*)
from business_licenses_staging;

-- 5. Check for duplicate rows--
select 
    count(*) as duplicate_groups,
   coalesce(sum(dup_count - 1),0) as total_duplicate_rows
from (
   select 
        `LICENSE ID`,
        `ACCOUNT NUMBER`,
        `SITE NUMBER`,
        `LEGAL NAME`,
        `ZIP CODE`,
        `LICENSE CODE`,
        `LICENSE NUMBER`,
        count(*) as dup_count
   from business_licenses_staging
   group by
        `LICENSE ID`,
        `ACCOUNT NUMBER`,
        `SITE NUMBER`,
        `LEGAL NAME`,
        `ZIP CODE`,
        `LICENSE CODE`,
        `LICENSE NUMBER`
   having count(*) > 1
) duplicates;
