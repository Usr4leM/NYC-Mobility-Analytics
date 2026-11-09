# Phase 02 --- Data Profiling

## Overview

The Data Profiling phase examines the structure, completeness,
uniqueness, and statistical characteristics of the raw NYC TLC mobility
datasets. It establishes an initial understanding of the data before
applying data quality rules, cleaning operations, or transformations.

This phase is implemented entirely in SQL using DuckDB and operates on
the raw views created during **Phase 01 --- Data Ingestion**.

The profiling process is organized into five steps:

## 1. Dataset Overview

**Script:** `01_dataset_overview.sql`

Provides a high-level overview of the datasets by measuring the total
number of records in each raw view.

**Main objective:** - Determine the size of each dataset. - Establish a
baseline record count for subsequent profiling and validation.

## 2. Schema Exploration

**Script:** `02_schema_exploration.sql`

Examines the database objects and the structure of each raw dataset.

**Main objective:** - Identify the available tables and views. - Inspect
column names and data types. - Understand schema differences across
datasets. - Establish the structural context required for further
analysis.

## 3. NULL Analysis

**Script:** `03_null_analysis.sql`

Measures missing values across every column in each dataset.

**Main objective:** - Count NULL and non-NULL values per column. -
Calculate the NULL percentage relative to the total number of records. -
Identify columns with substantial missingness or entirely NULL values.

NULL values are measured and documented at this stage; their treatment
is deferred to the Data Quality and Data Cleaning phases.

## 4. Distinct Values

**Script:** `04_distinct_values.sql`

Measures the number of distinct non-NULL values in each column.

**Main objective:** - Calculate distinct-value counts and their
proportion relative to the total number of records. - Understand the
cardinality of each attribute. - Support the selection of appropriate
techniques for the subsequent distribution analysis.

Distinct counts are used as a profiling measure, not as a substitute for
frequency distributions.

## 5. Data Distribution

**Script:** `05_data_distribution.sql`

Examines how values are distributed across categorical, numerical, and
temporal attributes. The analysis is divided into five complementary
views:

### Frequency Distribution

-   Ranks the most frequent values for selected categorical, discrete,
    and low-cardinality attributes.
-   Preserves SQL NULL values explicitly.
-   Groups less frequent values into an `Other (Long Tail)` category.
-   Calculates percentages after aggregating the long tail.

### Numerical Distribution

-   Calculates descriptive statistics, including minimum, maximum, mean,
    median, and sample standard deviation.
-   Measures the 25th, 75th, 90th, and 95th percentiles.
-   Counts zero and negative values as potential data quality
    indicators.

### Temporal Coverage

-   Examines timestamp completeness and temporal boundaries.
-   Calculates minimum, 1st percentile, median, 99th percentile, and
    maximum timestamps.

### Daily Distribution

-   Aggregates timestamp records by calendar date.
-   Describes daily record volumes and identifies dates represented in
    each temporal attribute.

### Hourly Distribution

-   Extracts the hour of day from each valid timestamp.
-   Aggregates records into hourly groups to examine time-of-day
    patterns.

## Project Structure

``` text
02_data_profiling/
├── 00_run_data_profiling.sql
├── 01_dataset_overview.sql
├── 02_schema_exploration.sql
├── 03_null_analysis.sql
├── 04_distinct_values.sql
└── 05_data_distribution.sql
```

## Execution

The Data Profiling phase can be executed in two ways.

### Full Phase Execution

Run the master script from the project root using the DuckDB CLI:

``` sql
.read sql/02_data_profiling/00_run_data_profiling.sql
```

The master script executes all five profiling scripts sequentially:

1.  `01_dataset_overview.sql`
2.  `02_schema_exploration.sql`
3.  `03_null_analysis.sql`
4.  `04_distinct_values.sql`
5.  `05_data_distribution.sql`

### Individual Script Execution

Each profiling script can also be executed independently when a specific
analysis needs to be performed:

``` sql
.read sql/02_data_profiling/01_dataset_overview.sql
.read sql/02_data_profiling/02_schema_exploration.sql
.read sql/02_data_profiling/03_null_analysis.sql
.read sql/02_data_profiling/04_distinct_values.sql
.read sql/02_data_profiling/05_data_distribution.sql
```

### Execution Logs

Each script records its execution output in a dedicated log file under:

``` text
logs/data_profiling/
```

## Outcome

At the end of this phase, the project has an initial, structured
understanding of:

-   Dataset sizes and schemas.
-   Missing-value patterns.
-   Column cardinality.
-   Categorical and numerical value distributions.
-   Temporal coverage and activity patterns.

The findings provide the foundation for **Phase 03 --- Data Quality**,
where potential issues identified during profiling will be investigated
against explicit validation rules. Unusual values are not automatically
classified as errors; their validity must be assessed in context.