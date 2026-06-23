#!/bin/bash

# ==============================================================================
# BigQuery -> Cloud Storage Results Export Script
# Project: C.A.R.T. (Cloud Analytics for Retail Transactions)
# ==============================================================================

PROJECT_ID="ccbd-20260619-danieletambone"
DATASET="cart_dataset"
BUCKET_DEST="gs://ccbd-20260619-danieletambone-bucket/export_cli"

echo "🚀 Starting export of analytical queries to Google Cloud Storage..."
echo "----------------------------------------------------------------------"

# Function to automate temp table creation, extraction, and cleanup
export_to_gcs() {
    local sql_file=$1
    local temp_table=$2
    local output_csv=$3

    echo "⏳ Processing: $output_csv"
    
    # 1. Execute the query and save to a temporary table
    bq query \
      --use_legacy_sql=false \
      --destination_table="${PROJECT_ID}:${DATASET}.${temp_table}" \
      --replace \
      "$(cat ${sql_file})" > /dev/null

    # 2. Extract the table to the GCS bucket
    bq extract \
      --destination_format=CSV \
      --print_header=true \
      "${PROJECT_ID}:${DATASET}.${temp_table}" \
      "${BUCKET_DEST}/${output_csv}" > /dev/null

    # 3. Delete the temporary table to free up BigQuery storage
    bq rm -f -t "${PROJECT_ID}:${DATASET}.${temp_table}"

    echo "✅ Successfully saved: ${BUCKET_DEST}/${output_csv}"
}

# Execute the function for all queries with updated English filenames
export_to_gcs "sql/query/01_query.sql" "temp_q1" "01_revenue_trend.csv"
export_to_gcs "sql/query/02_query.sql" "temp_q2" "02_sales_geography.csv"
export_to_gcs "sql/query/03_query.sql" "temp_q3" "03_purchasing_behavior.csv"
export_to_gcs "sql/query/04_query_full.sql" "temp_q4" "04_rfm_full.csv"
export_to_gcs "sql/query/05_query.sql" "temp_q5" "05_cohort_analysis.csv"
export_to_gcs "sql/query/06_query.sql" "temp_q6" "06_pareto_analysis.csv"

# Extracting the enriched customers table (already exists, no query needed)
echo "⏳ Processing: 07_customers_enriched.csv"
bq extract \
  --destination_format=CSV \
  --print_header=true \
  "${PROJECT_ID}:${DATASET}.dim_customers_enriched" \
  "${BUCKET_DEST}/07_customers_enriched.csv" > /dev/null
echo "✅ Successfully saved: ${BUCKET_DEST}/07_customers_enriched.csv"

echo "----------------------------------------------------------------------"
echo "🎉 Export completed! All CSV files are available in the Bucket."