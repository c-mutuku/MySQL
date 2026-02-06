# MySQL Data Analysis Projects

This repository contains multiple SQL-based data analysis projects demonstrating data cleaning, transformation, and analytical querying on large public datasets.


## Project 1: NYC Vehicle Collisions Analysis

### Overview
End-to-end SQL data cleaning and analysis project using NYC motor vehicle collision data.  
The project builds a structured database from raw records and analyzes crash patterns, locations, contributing factors, and severity to surface public-safety insights.


### Workflow Summary

#### Data Preparation & Cleaning
- Loaded raw data into a staging table for controlled processing
- Processed data in batches to handle large volume (~2.2M records)
- Standardized date and time fields to proper SQL data types
- Cleaned and normalized text fields (street names, vehicle types)
- Mapped inconsistent vehicle and street suffix codes to standardized categories
- Validated data integrity and uniqueness after transformations

#### Analysis
- Identified crash trends over time (hour, day, year)
- Analyzed collision distribution by borough and location
- Examined leading contributing factors
- Assessed injury and fatality severity across scenarios
- Compared crash frequency and severity by vehicle type


### 📂 Data Source
[Motor Vehicle Collisions – Crashes (NYC Open Data)](https://data.cityofnewyork.us/d/h9gi-nx95)

> Raw data is not included in this repository due to size.


### Visualization
Power BI dashboards were built to present key findings.  
Dashboard screenshots are included in the `screenshots/` folder.


### Tools Used
- MySQL 8.0
- Power BI
- Excel (initial inspection)


## Project 2: Chicago Business Licenses Analysis

### Overview
Comprehensive data cleaning and analysis pipeline for the Chicago business licenses dataset.  
The project focuses on **data quality, business operations, and geographic distribution**, prioritizing high-impact records to produce **analysis-ready datasets**.


### Workflow Summary

#### Data Preparation & Cleaning

- Loaded raw data into **staging tables** for safe transformations.  
- Focused on **top 10 cities**, covering ~90%+ of records for efficiency.  
- Standardized **text fields** (legal name, address) and **geographic fields** (city, state).  
- Applied **date standardization** for 8 date fields and converted empty strings to `NULL`.  
- Address standardization using **street suffix mapping**.  
- Applied **Soundex algorithm** and mapping tables for high-impact city name corrections.  
- Handled **duplicates** and used batch processing for large datasets (~1M+ records).

#### Analysis

- **Basic Descriptive Analysis**: Business counts, license types, and status distribution.  
- **Geographic Analysis**: Concentration by city, ward density, and license type distribution.  
- **Temporal Analysis**: Year-over-year growth, monthly patterns, and application-to-issuance durations.  
- **Business Health Analysis**: License duration, lifecycle status (active vs. terminated), and multiple license patterns.  
- Focused on **high-volume cities** for strategic insights while avoiding low-impact variations.


### 📂 Data Source

[Chicago Business Licenses – Open Data portal](https://catalog.data.gov/dataset/business-licenses)

> Raw data is not included in this repository due to size.


### Tools Used

- MySQL 8.0  
- Excel 
- Power BI 
