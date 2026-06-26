# Setup Guide

## 1. Install and Initialize the Google Cloud CLI

Please follow the official Google Cloud documentation to install the SDK: [Google Cloud CLI Installation](https://docs.cloud.google.com/sdk/docs/install-sdk).

## 2. Create the GCP Project and Bucket

```bash
gcloud projects create ccbd-20260619-danieletambone --name="CCBD Exam 2026"
gcloud config set project ccbd-20260619-danieletambone
gcloud storage buckets create gs://ccbd-20260619-danieletambone-bucket --location=europe-west8 --uniform-bucket-level-access

```

## 3. Link the Billing Account

```bash
gcloud billing projects describe ccbd-20260619-danieletambone
gcloud billing accounts list
gcloud billing projects link ccbd-20260619-danieletambone --billing-account=XXXXXX-XXXXXX-XXXXXX

```

## 4. Configure Service Account and IAM Permissions

```bash
SA="ccbd-exam-2026-sa"
PROJECT="ccbd-20260619-danieletambone"

gcloud iam service-accounts create $SA --display-name="CCBD notebook"

gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$SA@$PROJECT.iam.gserviceaccount.com" --role="roles/bigquery.jobUser"
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$SA@$PROJECT.iam.gserviceaccount.com" --role="roles/bigquery.dataEditor"
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$SA@$PROJECT.iam.gserviceaccount.com" --role="roles/bigquery.readSessionUser"

gcloud storage buckets add-iam-policy-binding gs://ccbd-20260619-danieletambone-bucket --member="serviceAccount:$SA@$PROJECT.iam.gserviceaccount.com" --role="roles/storage.objectAdmin"

gcloud iam service-accounts keys create ./ccbd-exam-2026-sa-key.json --iam-account=$SA@$PROJECT.iam.gserviceaccount.com

```

## 5. Local Preprocessing and Data Ingestion

```bash
python3 -m venv venvCART
source venvCART/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

python3 src/download_data.py
python3 src/clean_data.py

gcloud config set storage/parallel_composite_upload_enabled False
gcloud storage cp data/online_retail_clean.csv gs://ccbd-20260619-danieletambone-bucket/
gcloud storage ls gs://ccbd-20260619-danieletambone-bucket/

```

## 6. BigQuery Setup and Execution

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/ccbd-exam-2026-sa-key.json"

chmod +x scripts/setup_star_schema.sh
./scripts/setup_star_schema.sh

jupyter lab
# -> Run: 01_query.ipynb

chmod +x scripts/export_to_gcs.sh
./scripts/export_to_gcs.sh

```
