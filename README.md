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
- MySQL
- Power BI
- Excel (initial inspection)
