/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 01 - DATA INGESTION
 SCRIPT: 01_read_parquet_files.sql

 DESCRIPTION:
 Initial accessibility validation and inspection of the
 original NYC TLC Parquet datasets using DuckDB.

 EXECUTION:
 Run from the project root:

 .read sql/01_data_ingestion/01_read_parquet_files.sql

 RUNTIME CONFIGURATION:
 .echo on  -> Display executed commands.
 .timer on -> Measure query execution time.
 .bail on  -> Stop execution on SQL errors.
 .log      -> Record session activity.
=================================================================
*/

-- ==============================================================
-- RUNTIME ENVIRONMENT CONFIGURATION
-- ==============================================================

.timer on
.bail on
.log logs/data_ingestion/read_parquet_files.log
.echo on

-- =========================================================
-- PARQUET ACCESSIBILITY & INITIAL INSPECTION
-- =========================================================

-- Yellow Taxi
SELECT *
FROM read_parquet(
    'data/raw/yellow_taxi/*.parquet'
)
LIMIT 10;

-- Green Taxi
SELECT *
FROM read_parquet(
    'data/raw/green_taxi/*.parquet'
)
LIMIT 10;

-- For-Hire Vehicle
SELECT *
FROM read_parquet(
    'data/raw/for_hire_vehicle/*.parquet'
)
LIMIT 10;

-- High-Volume For-Hire Vehicle
SELECT *
FROM read_parquet(
    'data/raw/high_volume_for_hire_vehicle/*.parquet'
)
LIMIT 10;

.log stderr
.echo off
.timer off