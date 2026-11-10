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
 .bail on  -> Stop execution on SQL errors.
 .timer on -> Measure query execution time.
 .echo on  -> Display executed commands.
=================================================================
*/

-- ==============================================================
-- RUNTIME ENVIRONMENT CONFIGURATION
-- ==============================================================

.bail on
.timer on
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

-- For-Hire Vehicle (FHV)
SELECT *
FROM read_parquet(
    'data/raw/for_hire_vehicle/*.parquet'
)
LIMIT 10;

-- High-Volume For-Hire Vehicle (HVFHV)
SELECT *
FROM read_parquet(
    'data/raw/high_volume_for_hire_vehicle/*.parquet'
)
LIMIT 10;

-- =========================================================
-- RUNTIME ENVIRONMENT CLEANUP
-- =========================================================

.echo off
.timer off
.bail off