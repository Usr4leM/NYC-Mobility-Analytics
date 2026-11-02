/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 01 - DATA INGESTION
 SCRIPT: 02_create_raw_views.sql

 DESCRIPTION:
 Creates logical views over the original Parquet datasets.
 These views provide a reusable SQL interface for accessing
 raw data without physically duplicating the source records.

 EXECUTION:
 Run from the project root:

 .read sql/01_data_ingestion/02_create_raw_views.sql

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
.log logs/data_ingestion/create_raw_views.log
.echo on

-- =========================================================
-- RAW LAYER - VIEW CREATION
-- =========================================================

-- Yellow Taxi
CREATE OR REPLACE VIEW yellow_taxi_raw AS
SELECT *
FROM read_parquet(
    'data/raw/yellow_taxi/*.parquet'
);

-- Green Taxi
CREATE OR REPLACE VIEW green_taxi_raw AS
SELECT *
FROM read_parquet(
    'data/raw/green_taxi/*.parquet'
);

-- For-Hire Vehicle
CREATE OR REPLACE VIEW for_hire_vehicle_raw AS
SELECT *
FROM read_parquet(
    'data/raw/for_hire_vehicle/*.parquet'
);

-- High-Volume For-Hire Vehicle
CREATE OR REPLACE VIEW high_volume_for_hire_vehicle_raw AS
SELECT *
FROM read_parquet(
    'data/raw/high_volume_for_hire_vehicle/*.parquet'
);

-- =========================================================
-- RAW LAYER - VIEW VALIDATION
-- =========================================================

SELECT
    table_name,
    table_type
FROM information_schema.tables
WHERE table_name IN (
    'yellow_taxi_raw',
    'green_taxi_raw',
    'for_hire_vehicle_raw',
    'high_volume_for_hire_vehicle_raw'
)
ORDER BY table_name;

SELECT 'Data Ingestion Completed Successfully' AS ingestion_status,
        current_timestamp AS completion_time;

.log stderr
.echo off
.timer off