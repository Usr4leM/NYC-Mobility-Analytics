/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 02 - DATA PROFILING
 SCRIPT: 00_run_data_profiling.sql

 DESCRIPTION:
 Master execution script for the Data Profiling phase.

 Executes all five profiling scripts sequentially:

 01. Dataset Overview
 02. Schema Exploration
 03. NULL Analysis
 04. Distinct Values
 05. Data Distribution

 EXECUTION:
 Run from the project root:

 .read sql/02_data_profiling/00_run_data_profiling.sql
=================================================================
*/

-- ==============================================================
-- DATA PROFILING EXECUTION
-- ==============================================================

.read sql/02_data_profiling/01_dataset_overview.sql
.read sql/02_data_profiling/02_schema_exploration.sql
.read sql/02_data_profiling/03_null_analysis.sql
.read sql/02_data_profiling/04_distinct_values.sql
.read sql/02_data_profiling/05_data_distribution.sql