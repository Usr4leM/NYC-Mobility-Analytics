/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 02 - DATA PROFILING
 SCRIPT: 03_null_analysis.sql

 DESCRIPTION:
 Analyzes missing values across raw datasets, calculating
 NULL counts and percentages for each column.

 EXECUTION:
 Run from the project root:

 .read sql/02_data_profiling/03_null_analysis.sql

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
.log logs/data_profiling/null_analysis.log
.echo on

-- =========================================================
-- MULTI-DATASET MISSING VALUES ANALYSIS (NULLS AUDIT)
-- =========================================================

-- Yellow Taxi
WITH null_counts AS (
    SELECT 
        COUNT(*) AS total_records,
        -- Automatically counts NULLs for each column in the table
        SUM((COLUMNS(*) IS NULL)::INT)
    FROM main.yellow_taxi_raw
)
SELECT 
    column_name,
    null_count,
    total_records,
    -- Calculates the percentage of missing data per column
    ROUND((null_count * 100.0) / total_records, 2) AS null_percentage
FROM (
    -- Converts columnar aggregation results into rows
    UNPIVOT null_counts
    ON COLUMNS(* EXCLUDE (total_records))
    INTO 
        NAME column_name
        VALUE null_count
)
ORDER BY 
    null_count DESC,
    null_percentage DESC;

-- Green Taxi
WITH null_counts AS (
    SELECT 
        COUNT(*) AS total_records,
        SUM((COLUMNS(*) IS NULL)::INT)
    FROM main.green_taxi_raw
)
SELECT 
    column_name,
    null_count,
    total_records,
    ROUND((null_count * 100.0) / total_records, 2) AS null_percentage
FROM (
    UNPIVOT null_counts
    ON COLUMNS(* EXCLUDE (total_records))
    INTO 
        NAME column_name
        VALUE null_count
)
ORDER BY 
    null_count DESC,
    null_percentage DESC;

-- For-Hire Vehicle
WITH null_counts AS (
    SELECT 
        COUNT(*) AS total_records,
        SUM((COLUMNS(*) IS NULL)::INT)
    FROM main.for_hire_vehicle_raw
)
SELECT 
    column_name,
    null_count,
    total_records,
    ROUND((null_count * 100.0) / total_records, 2) AS null_percentage
FROM (
    UNPIVOT null_counts
    ON COLUMNS(* EXCLUDE (total_records))
    INTO 
        NAME column_name
        VALUE null_count
)
ORDER BY 
    null_count DESC,
    null_percentage DESC;

-- High-Volume For-Hire Vehicle
WITH null_counts AS (
    SELECT 
        COUNT(*) AS total_records,
        SUM((COLUMNS(*) IS NULL)::INT)
    FROM main.high_volume_for_hire_vehicle_raw
)
SELECT 
    column_name,
    null_count,
    total_records,
    ROUND((null_count * 100.0) / total_records, 2) AS null_percentage
FROM (
    UNPIVOT null_counts
    ON COLUMNS(* EXCLUDE (total_records))
    INTO 
        NAME column_name
        VALUE null_count
)
ORDER BY 
    null_count DESC,
    null_percentage DESC;

-- =========================================================
-- RUNTIME ENVIRONMENT CLEANUP
-- =========================================================

.log off
.echo off
.timer off