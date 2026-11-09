/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 02 - DATA PROFILING
 SCRIPT: 01_dataset_overview.sql

 DESCRIPTION:
 Analyzes the total number of records available in each
 raw dataset.

 EXECUTION:
 Run from the project root:

 .read sql/02_data_profiling/01_dataset_overview.sql

 RUNTIME CONFIGURATION:
 .timer on -> Measure query execution time.
 .bail on  -> Stop execution on SQL errors.
 .log      -> Record execution output in a log file.
 .echo on  -> Display executed commands.
=================================================================
*/

-- ==============================================================
-- RUNTIME ENVIRONMENT CONFIGURATION
-- ==============================================================

.timer on
.bail on
.log logs/data_profiling/dataset_overview.log
.echo on

-- =========================================================
-- DATASET RECORD COUNT
-- =========================================================

-- Yellow Taxi
SELECT 
    'Yellow Taxi' AS dataset,
    COUNT(*) AS total_records
FROM yellow_taxi_raw

UNION ALL

-- Green Taxi
SELECT 
    'Green Taxi' AS dataset,
    COUNT(*) AS total_records
FROM green_taxi_raw

UNION ALL

-- For-Hire Vehicle
SELECT
    'For-Hire Vehicle' AS dataset,
    COUNT(*) AS total_records
FROM for_hire_vehicle_raw

UNION ALL

-- High-Volume For-Hire Vehicle
SELECT
    'High-Volume For-Hire Vehicle' AS dataset,
    COUNT(*) AS total_records
FROM high_volume_for_hire_vehicle_raw;

-- =========================================================
-- RUNTIME ENVIRONMENT CLEANUP
-- =========================================================

.log off
.echo off
.timer off