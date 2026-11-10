/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 02 - DATA PROFILING
 SCRIPT: 05_data_distribution.sql

 DESCRIPTION:
 Generates comprehensive statistical and frequency distributions across all
 raw NYC TLC mobility datasets (Yellow Taxi, Green Taxi, FHV, and HVFHV).

 - Frequency-Based Attributes: Top-10 frequency rankings with explicit SQL NULL
   preservation and long-tail aggregation ('Other (Long Tail)').

 - Numerical: Summary statistics (min, max, mean, median, stddev, quartiles/percentiles)
   and data quality indicators (zero and negative value counts).

 - Temporal: Coverage boundaries (min, p01, median, p99, max) alongside daily
   and hourly volume distributions.

 EXECUTION:
 Run from the project root:

 .read sql/02_data_profiling/05_data_distribution.sql

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
-- FREQUENCY DISTRIBUTION
-- =========================================================

WITH base_prep AS (
    -- Standardize data types to VARCHAR and unpivot each dataset independently using INCLUDE NULLS
    -- to avoid schema mismatches and preserve genuine SQL NULLs

    -- Yellow Taxi
    FROM (
        SELECT
            'Yellow Taxi' AS dataset,
            CAST(VendorID AS VARCHAR) AS VendorID,
            CAST(payment_type AS VARCHAR) AS payment_type,
            CAST(RatecodeID AS VARCHAR) AS RatecodeID,
            CAST(store_and_fwd_flag AS VARCHAR) AS store_and_fwd_flag,
            CAST(request_source AS VARCHAR) AS request_source,
            CAST(passenger_count AS VARCHAR) AS passenger_count,
            CAST(PULocationID AS VARCHAR) AS PULocationID,
            CAST(DOLocationID AS VARCHAR) AS DOLocationID,
            -- Enforce two decimal places via DECIMAL before string conversion to preserve trailing zeros
            CAST(CAST(extra AS DECIMAL(10, 2)) AS VARCHAR) AS extra,
            CAST(CAST(mta_tax AS DECIMAL(10, 2)) AS VARCHAR) AS mta_tax,
            CAST(CAST(improvement_surcharge AS DECIMAL(10, 2)) AS VARCHAR) AS improvement_surcharge,
            CAST(CAST(congestion_surcharge AS DECIMAL(10, 2)) AS VARCHAR) AS congestion_surcharge,
            CAST(CAST(Airport_fee AS DECIMAL(10, 2)) AS VARCHAR) AS Airport_fee,
            CAST(CAST(cbd_congestion_fee AS DECIMAL(10, 2)) AS VARCHAR) AS cbd_congestion_fee
        FROM main.yellow_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        column_value FOR column_name IN (COLUMNS(* EXCLUDE (dataset)))
    )

    UNION ALL

    -- Green Taxi
    FROM (
        SELECT
            'Green Taxi' AS dataset,
            CAST(VendorID AS VARCHAR) AS VendorID,
            CAST(payment_type AS VARCHAR) AS payment_type,
            CAST(RatecodeID AS VARCHAR) AS RatecodeID,
            CAST(store_and_fwd_flag AS VARCHAR) AS store_and_fwd_flag,
            CAST(request_source AS VARCHAR) AS request_source,
            CAST(passenger_count AS VARCHAR) AS passenger_count,
            CAST(PULocationID AS VARCHAR) AS PULocationID,
            CAST(DOLocationID AS VARCHAR) AS DOLocationID,
            CAST(trip_type AS VARCHAR) AS trip_type,
            CAST(CAST(extra AS DECIMAL(10, 2)) AS VARCHAR) AS extra,
            CAST(CAST(mta_tax AS DECIMAL(10, 2)) AS VARCHAR) AS mta_tax,
            CAST(CAST(improvement_surcharge AS DECIMAL(10, 2)) AS VARCHAR) AS improvement_surcharge,
            CAST(CAST(congestion_surcharge AS DECIMAL(10, 2)) AS VARCHAR) AS congestion_surcharge,
            CAST(CAST(cbd_congestion_fee AS DECIMAL(10, 2)) AS VARCHAR) AS cbd_congestion_fee
        FROM main.green_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        column_value FOR column_name IN (COLUMNS(* EXCLUDE (dataset)))
    )

    UNION ALL

    -- For-Hire Vehicle
    FROM (
        SELECT
            'For-Hire Vehicle' AS dataset,
            CAST(dispatching_base_num AS VARCHAR) AS dispatching_base_num,
            CAST(PUlocationID AS VARCHAR) AS PUlocationID,
            CAST(DOlocationID AS VARCHAR) AS DOlocationID,
            CAST(Affiliated_base_number AS VARCHAR) AS Affiliated_base_number
        FROM main.for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        column_value FOR column_name IN (COLUMNS(* EXCLUDE (dataset)))
    )

    UNION ALL

    -- High-Volume For-Hire Vehicle
    FROM (
        SELECT
            'High-Volume For-Hire Vehicle' AS dataset,
            CAST(hvfhs_license_num AS VARCHAR) AS hvfhs_license_num,
            CAST(dispatching_base_num AS VARCHAR) AS dispatching_base_num,
            CAST(originating_base_num AS VARCHAR) AS originating_base_num,
            CAST(PULocationID AS VARCHAR) AS PULocationID,
            CAST(DOLocationID AS VARCHAR) AS DOLocationID,
            CAST(shared_request_flag AS VARCHAR) AS shared_request_flag,
            CAST(shared_match_flag AS VARCHAR) AS shared_match_flag,
            CAST(access_a_ride_flag AS VARCHAR) AS access_a_ride_flag,
            CAST(wav_request_flag AS VARCHAR) AS wav_request_flag,
            CAST(wav_match_flag AS VARCHAR) AS wav_match_flag,
            CAST(CAST(congestion_surcharge AS DECIMAL(10, 2)) AS VARCHAR) AS congestion_surcharge,
            CAST(CAST(airport_fee AS DECIMAL(10, 2)) AS VARCHAR) AS airport_fee,
            CAST(CAST(cbd_congestion_fee AS DECIMAL(10, 2)) AS VARCHAR) AS cbd_congestion_fee
        FROM main.high_volume_for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        column_value FOR column_name IN (COLUMNS(* EXCLUDE (dataset)))
    )
),
frequency_counts AS (
    -- Aggregate record counts per attribute value prior to ranking
    SELECT
        dataset,
        column_name,
        column_value,
        COUNT(*) AS record_count
    FROM base_prep
    GROUP BY 
        dataset,
        column_name,
        column_value
),
ranked_counts AS (
    -- Rank attribute values by descending frequency within each dataset and column
    SELECT
        dataset,
        column_name,
        column_value,
        record_count,
        ROW_NUMBER() OVER (
            PARTITION BY dataset, column_name 
            ORDER BY record_count DESC, column_value NULLS LAST
        ) AS rn
    FROM frequency_counts
),
collapsed_counts AS (
    -- Keep Top 10 values and always preserve SQL NULLs explicitly, regardless of their rank.
    -- Convention: 'Other (Long Tail)' is used as a sentinel label to group remaining values,
    -- assuming structured domain values will not collide with this string.
    SELECT
        dataset,
        column_name,
        CASE 
            WHEN rn <= 10 OR column_value IS NULL THEN column_value 
            ELSE 'Other (Long Tail)' 
        END AS column_value,
        SUM(record_count) AS record_count,
        CASE 
            WHEN rn <= 10 THEN rn 
            WHEN column_value IS NULL THEN 11 
            ELSE 12 
        END AS sort_order
    FROM ranked_counts
    GROUP BY 
        dataset,
        column_name,
        CASE 
            WHEN rn <= 10 OR column_value IS NULL THEN column_value 
            ELSE 'Other (Long Tail)' 
        END,
        CASE 
            WHEN rn <= 10 THEN rn 
            WHEN column_value IS NULL THEN 11 
            ELSE 12 
        END
)
-- Calculate percentages after collapsing long-tail values to preserve the correct distribution.
SELECT
    dataset,
    column_name,
    column_value,
    record_count,
    ROUND(
        record_count * 100.0 /
        NULLIF(SUM(record_count) OVER (PARTITION BY dataset, column_name), 0),
        2
    ) AS percentage
FROM collapsed_counts
ORDER BY
    dataset,
    column_name,
    sort_order;

-- =========================================================
-- NUMERICAL DISTRIBUTION
-- =========================================================

WITH base_prep AS (

    -- Yellow Taxi
    FROM (
        SELECT
            'Yellow Taxi' AS dataset,
            CAST(trip_distance AS DOUBLE) AS trip_distance,
            CAST(fare_amount AS DOUBLE) AS fare_amount,
            CAST(tip_amount AS DOUBLE) AS tip_amount,
            CAST(tolls_amount AS DOUBLE) AS tolls_amount,
            CAST(total_amount AS DOUBLE) AS total_amount
        FROM main.yellow_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        column_value FOR column_name IN (COLUMNS(* EXCLUDE (dataset)))
    )

    UNION ALL

    -- Green Taxi
    FROM (
        SELECT
            'Green Taxi' AS dataset,
            CAST(trip_distance AS DOUBLE) AS trip_distance,
            CAST(fare_amount AS DOUBLE) AS fare_amount,
            CAST(tip_amount AS DOUBLE) AS tip_amount,
            CAST(tolls_amount AS DOUBLE) AS tolls_amount,
            CAST(total_amount AS DOUBLE) AS total_amount
        FROM main.green_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        column_value FOR column_name IN (COLUMNS(* EXCLUDE (dataset)))
    )

    UNION ALL

    -- High-Volume For-Hire Vehicle
    FROM (
        SELECT
            'High-Volume For-Hire Vehicle' AS dataset,
            CAST(trip_miles AS DOUBLE) AS trip_miles,
            CAST(trip_time AS DOUBLE) AS trip_time,
            CAST(base_passenger_fare AS DOUBLE) AS base_passenger_fare,
            CAST(tolls AS DOUBLE) AS tolls,
            CAST(tips AS DOUBLE) AS tips,
            CAST(driver_pay AS DOUBLE) AS driver_pay,
            CAST(bcf AS DOUBLE) AS bcf,
            CAST(sales_tax AS DOUBLE) AS sales_tax
        FROM main.high_volume_for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        column_value FOR column_name IN (COLUMNS(* EXCLUDE (dataset)))
    )
)

-- Compute descriptive statistics, dispersion percentiles, and potential data quality indicators (zero and negative counts) per numerical attribute.
SELECT
    dataset,
    column_name,

    COUNT(*) AS total_records,
    COUNT(column_value) AS non_null_count,
    COUNT(*) - COUNT(column_value) AS null_count,

    ROUND(MIN(column_value), 2) AS min_value,
    ROUND(MAX(column_value), 2) AS max_value,
    ROUND(AVG(column_value), 2) AS average,
    ROUND(MEDIAN(column_value), 2) AS median,
    ROUND(STDDEV_SAMP(column_value), 2) AS standard_deviation,

    ROUND(QUANTILE_CONT(column_value, 0.25), 2) AS percentile_25,
    ROUND(QUANTILE_CONT(column_value, 0.75), 2) AS percentile_75,
    ROUND(QUANTILE_CONT(column_value, 0.90), 2) AS percentile_90,
    ROUND(QUANTILE_CONT(column_value, 0.95), 2) AS percentile_95,

    -- Potential data quality indicators
    COUNT(*) FILTER (WHERE column_value = 0) AS zero_count,
    COUNT(*) FILTER (WHERE column_value < 0) AS negative_count

FROM base_prep
GROUP BY
    dataset,
    column_name
ORDER BY
    dataset,
    column_name;

-- =========================================================
-- TEMPORAL DISTRIBUTION
-- =========================================================

-- Temporal Coverage
WITH base_prep AS (

    -- Yellow Taxi
    FROM (
        SELECT
            'Yellow Taxi' AS dataset,
            CAST(tpep_pickup_datetime AS TIMESTAMP) AS tpep_pickup_datetime,
            CAST(tpep_dropoff_datetime AS TIMESTAMP) AS tpep_dropoff_datetime
        FROM main.yellow_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- Green Taxi
    FROM (
        SELECT
            'Green Taxi' AS dataset,
            CAST(lpep_pickup_datetime AS TIMESTAMP) AS lpep_pickup_datetime,
            CAST(lpep_dropoff_datetime AS TIMESTAMP) AS lpep_dropoff_datetime
        FROM main.green_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- For-Hire Vehicle
    FROM (
        SELECT
            'For-Hire Vehicle' AS dataset,
            CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
            CAST(dropOff_datetime AS TIMESTAMP) AS dropOff_datetime
        FROM main.for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- High-Volume For-Hire Vehicle
    FROM (
        SELECT
            'High-Volume For-Hire Vehicle' AS dataset,
            CAST(request_datetime AS TIMESTAMP) AS request_datetime,
            CAST(on_scene_datetime AS TIMESTAMP) AS on_scene_datetime,
            CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
            CAST(dropoff_datetime AS TIMESTAMP) AS dropoff_datetime
        FROM main.high_volume_for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )
)

-- Evaluate timestamp completeness and boundary percentiles (min, p01, median, p99, max) to detect out-of-range dates.
SELECT
    dataset,
    column_name,

    COUNT(*) AS total_records,
    COUNT(timestamp_value) AS non_null_count,
    COUNT(*) - COUNT(timestamp_value) AS null_count,

    MIN(timestamp_value) AS min_datetime,
    QUANTILE_CONT(timestamp_value, 0.01) AS p01_datetime,
    MEDIAN(timestamp_value) AS median_datetime,
    QUANTILE_CONT(timestamp_value, 0.99) AS p99_datetime,
    MAX(timestamp_value) AS max_datetime

FROM base_prep
GROUP BY
    dataset,
    column_name
ORDER BY
    dataset,
    column_name;

-- Daily Distribution
WITH base_prep AS (

    -- Yellow Taxi
    FROM (
        SELECT
            'Yellow Taxi' AS dataset,
            CAST(tpep_pickup_datetime AS TIMESTAMP) AS tpep_pickup_datetime,
            CAST(tpep_dropoff_datetime AS TIMESTAMP) AS tpep_dropoff_datetime
        FROM main.yellow_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- Green Taxi
    FROM (
        SELECT
            'Green Taxi' AS dataset,
            CAST(lpep_pickup_datetime AS TIMESTAMP) AS lpep_pickup_datetime,
            CAST(lpep_dropoff_datetime AS TIMESTAMP) AS lpep_dropoff_datetime
        FROM main.green_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- For-Hire Vehicle
    FROM (
        SELECT
            'For-Hire Vehicle' AS dataset,
            CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
            CAST(dropOff_datetime AS TIMESTAMP) AS dropOff_datetime
        FROM main.for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- High-Volume For-Hire Vehicle
    FROM (
        SELECT
            'High-Volume For-Hire Vehicle' AS dataset,
            CAST(request_datetime AS TIMESTAMP) AS request_datetime,
            CAST(on_scene_datetime AS TIMESTAMP) AS on_scene_datetime,
            CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
            CAST(dropoff_datetime AS TIMESTAMP) AS dropoff_datetime
        FROM main.high_volume_for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )
)

-- Aggregate valid timestamps by calendar date to profile daily record volumes and identify dates represented in the data.
SELECT
    dataset,
    column_name,
    CAST(timestamp_value AS DATE) AS date_value,
    COUNT(*) AS record_count

FROM base_prep
WHERE timestamp_value IS NOT NULL

GROUP BY
    dataset,
    column_name,
    CAST(timestamp_value AS DATE)

ORDER BY
    dataset,
    column_name,
    date_value;

-- Hourly Distribution
WITH base_prep AS (

    -- Yellow Taxi
    FROM (
        SELECT
            'Yellow Taxi' AS dataset,
            CAST(tpep_pickup_datetime AS TIMESTAMP) AS tpep_pickup_datetime,
            CAST(tpep_dropoff_datetime AS TIMESTAMP) AS tpep_dropoff_datetime
        FROM main.yellow_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- Green Taxi
    FROM (
        SELECT
            'Green Taxi' AS dataset,
            CAST(lpep_pickup_datetime AS TIMESTAMP) AS lpep_pickup_datetime,
            CAST(lpep_dropoff_datetime AS TIMESTAMP) AS lpep_dropoff_datetime
        FROM main.green_taxi_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- For-Hire Vehicle
    FROM (
        SELECT
            'For-Hire Vehicle' AS dataset,
            CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
            CAST(dropOff_datetime AS TIMESTAMP) AS dropOff_datetime
        FROM main.for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )

    UNION ALL

    -- High-Volume For-Hire Vehicle
    FROM (
        SELECT
            'High-Volume For-Hire Vehicle' AS dataset,
            CAST(request_datetime AS TIMESTAMP) AS request_datetime,
            CAST(on_scene_datetime AS TIMESTAMP) AS on_scene_datetime,
            CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
            CAST(dropoff_datetime AS TIMESTAMP) AS dropoff_datetime
        FROM main.high_volume_for_hire_vehicle_raw
    )
    UNPIVOT INCLUDE NULLS (
        timestamp_value FOR column_name IN (
            COLUMNS(* EXCLUDE (dataset))
        )
    )
)

-- Extract hour-of-day frequencies from valid timestamps to profile diurnal mobility patterns.
SELECT
    dataset,
    column_name,
    EXTRACT(HOUR FROM timestamp_value) AS hour_of_day,
    COUNT(*) AS record_count
FROM base_prep
WHERE timestamp_value IS NOT NULL
GROUP BY
    dataset,
    column_name,
    EXTRACT(HOUR FROM timestamp_value)
ORDER BY
    dataset,
    column_name,
    hour_of_day;

-- =========================================================
-- RUNTIME ENVIRONMENT CLEANUP
-- =========================================================

.echo off
.timer off
.bail off