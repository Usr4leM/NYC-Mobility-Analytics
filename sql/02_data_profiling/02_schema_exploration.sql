/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 02 - DATA PROFILING
 SCRIPT: 02_schema_exploration.sql

 DESCRIPTION:
 Explores the schema of each raw dataset, identifying
 column names, data types and column positions.

 EXECUTION:
 Run from the project root:

 .read sql/02_data_profiling/02_schema_exploration.sql

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
.log logs/data_profiling/schema_exploration.log
.echo on

-- =========================================================
-- DATABASE OBJECTS INVENTORY (METADATA DISCOVERY)
-- =========================================================

SELECT   
    table_catalog,
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'main'
ORDER BY table_name;

-- =========================================================
-- RAW DATASETS SCHEMA INSPECTION
-- =========================================================

-- Yellow Taxi
DESCRIBE main.yellow_taxi_raw;

-- Green Taxi
DESCRIBE main.green_taxi_raw;

-- For-Hire Vehicle
DESCRIBE main.for_hire_vehicle_raw;

-- High-Volume For-Hire Vehicle
DESCRIBE main.high_volume_for_hire_vehicle_raw;

-- =========================================================
-- RUNTIME ENVIRONMENT CLEANUP
-- =========================================================

.log off
.echo off
.timer off