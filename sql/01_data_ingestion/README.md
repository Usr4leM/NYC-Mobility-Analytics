# Phase 01 - Data Ingestion

## Overview

This phase focuses on accessing and ingesting the original
NYC TLC trip datasets stored in Apache Parquet format using DuckDB.

The objective is to make the raw datasets accessible for subsequent
data profiling, data quality assessment, cleaning, and exploratory
data analysis.

## Data Sources

The project uses the following datasets:

- Yellow Taxi
- Green Taxi
- For-Hire Vehicle (FHV)
- High Volume For-Hire Vehicle (HVFHV)

All original Parquet files are stored in the `data/raw/` directory.

## Scripts

### 01_read_parquet_files.sql

Used to read and inspect the original Parquet files directly
with DuckDB.

### 02_create_raw_views.sql

Creates SQL views over the original Parquet files.

These views provide a consistent way to access the raw datasets
without modifying the original files.

## Expected Results

After executing the scripts:

- All four datasets should be readable through DuckDB.
- Raw views should be available for subsequent SQL operations.
- Original Parquet files should remain unchanged.

## Notes

No data cleaning or transformation is performed during this phase.
The objective is only to access and expose the original datasets.