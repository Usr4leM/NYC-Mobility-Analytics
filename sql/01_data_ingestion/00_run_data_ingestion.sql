/*
=================================================================
 PROJECT: NYC-Mobility-Analytics
 PHASE: 01 - DATA INGESTION
 SCRIPT: 00_run_data_ingestion.sql

 DESCRIPTION:
 Master script responsible for executing the data ingestion
 workflow in the correct sequence.

 EXECUTION:
 Run from the project root:

 .read sql/01_data_ingestion/00_run_data_ingestion.sql

=================================================================
*/

-- =========================================================
-- 01. PARQUET FILE INSPECTION
-- =========================================================

.read sql/01_data_ingestion/01_read_parquet_files.sql

-- =========================================================
-- 02. RAW VIEWS CREATION
-- =========================================================

.read sql/01_data_ingestion/02_create_raw_views.sql