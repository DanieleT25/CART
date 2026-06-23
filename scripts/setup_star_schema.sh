#!/bin/bash

# ==============================================================================
# Data Warehouse Initialization and Ingestion Pipeline
# ==============================================================================

# Exit immediately if any command exits with a non-zero status
set -e

PROJECT_ID="ccbd-20260619-danieletambone"
DATASET="cart_dataset"
BUCKET_URI="gs://ccbd-20260619-danieletambone-bucket/online_retail_clean.csv"

echo "🚀 Initializing BigQuery infrastructure..."

# 1. Dataset Creation (If it already exists, fail silently and continue)
bq mk --dataset --location=europe-west8 "${PROJECT_ID}:${DATASET}" > /dev/null 2>&1 || true

# 2. INGESTION: Loading clean raw data from Google Cloud Storage
echo "📥 Ingesting raw data from GCS to BigQuery (raw_online_retail)..."
bq query --use_legacy_sql=false -- "
LOAD DATA OVERWRITE \`${PROJECT_ID}.${DATASET}.raw_online_retail\`
(
  InvoiceNo STRING,
  StockCode STRING,
  Description STRING,
  Quantity INT64,
  InvoiceDate TIMESTAMP,
  UnitPrice FLOAT64,
  CustomerID INT64,
  Country STRING
)
FROM FILES (
  format = 'CSV',
  uris = ['${BUCKET_URI}'],
  skip_leading_rows = 1
);" > /dev/null

# 3. Star Schema Modeling
# The '--' flag isolates the SQL block, preventing Bash from parsing embedded SQL comments
echo "🏗️ Building Dimensional Tables..."
bq query --use_legacy_sql=false -- "$(cat sql/star_schema/01_create_dim_customers.sql)" > /dev/null
bq query --use_legacy_sql=false -- "$(cat sql/star_schema/02_create_dim_products.sql)" > /dev/null
bq query --use_legacy_sql=false -- "$(cat sql/star_schema/03_create_dim_date.sql)" > /dev/null

echo "🏗️ Building Fact Table..."
bq query --use_legacy_sql=false -- "$(cat sql/star_schema/04_create_fact_sales.sql)" > /dev/null

echo "✅ Ingestion pipeline and Star Schema modeling completed successfully!"