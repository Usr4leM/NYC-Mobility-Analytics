/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 02 - DATA PROFILING
 SCRIPT: 04_distinct_values.sql

 DESCRIPTION:
 Analyzes the cardinality of each column across raw datasets,
 calculating distinct value counts and percentages relative
 to the total number of records.

 EXECUTION:
 Run from the project root:

 .read sql/02_data_profiling/04_distinct_values.sql

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
.log logs/data_profiling/distinct_values.log
.echo on

-- =========================================================
-- MULTI-DATASET DISTINCT VALUES ANALYSIS (CARDINALITY)
-- =========================================================

-- Yellow Taxi
WITH distinct_counts AS (
    SELECT 
        COUNT(*) AS total_records,
        -- Automatically counts distinct non-NULL values for each column
        COUNT(DISTINCT COLUMNS(*))
    FROM main.yellow_taxi_raw
)
SELECT 
    column_name,
    distinct_count,
    total_records,
    -- Calculates the percentage of distinct values per column
    ROUND((distinct_count * 100.0) / total_records, 2) AS distinct_percentage
FROM (
    -- Converts columnar aggregation results into rows
    UNPIVOT distinct_counts
    ON COLUMNS(* EXCLUDE (total_records))
    INTO 
        NAME column_name
        VALUE distinct_count
)
ORDER BY
    distinct_count DESC,
    distinct_percentage DESC;

-- Green Taxi
WITH distinct_counts AS (
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT COLUMNS(*))
    FROM main.green_taxi_raw
)
SELECT 
    column_name,
    distinct_count,
    total_records,
    ROUND((distinct_count * 100.0) / total_records, 2) AS distinct_percentage
FROM (
    UNPIVOT distinct_counts
    ON COLUMNS(* EXCLUDE (total_records))
    INTO 
        NAME column_name
        VALUE distinct_count
)
ORDER BY
    distinct_count DESC,
    distinct_percentage DESC;

-- For-Hire Vehicle
WITH distinct_counts AS (
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT COLUMNS(*))
    FROM main.for_hire_vehicle_raw
)
SELECT 
    column_name,
    distinct_count,
    total_records,
    ROUND((distinct_count * 100.0) / total_records, 2) AS distinct_percentage
FROM (
    UNPIVOT distinct_counts
    ON COLUMNS(* EXCLUDE (total_records))
    INTO 
        NAME column_name
        VALUE distinct_count
)
ORDER BY
    distinct_count DESC,
    distinct_percentage DESC;

-- High-Volume For-Hire Vehicle
WITH distinct_counts AS (
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT COLUMNS(*))
    FROM main.high_volume_for_hire_vehicle_raw
)
SELECT 
    column_name,
    distinct_count,
    total_records,
    ROUND((distinct_count * 100.0) / total_records, 2) AS distinct_percentage
FROM (
    UNPIVOT distinct_counts
    ON COLUMNS(* EXCLUDE (total_records))
    INTO 
        NAME column_name
        VALUE distinct_count
)
ORDER BY
    distinct_count DESC,
    distinct_percentage DESC;

-- =========================================================
-- RUNTIME ENVIRONMENT CLEANUP
-- =========================================================

.log off
.echo off
.timer off