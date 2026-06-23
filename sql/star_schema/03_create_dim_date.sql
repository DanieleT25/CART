-- Creation of the Date dimension table
CREATE OR REPLACE TABLE `ccbd-20260619-danieletambone.cart_dataset.dim_date` AS
WITH unique_dates AS (
  SELECT DISTINCT DATE(InvoiceDate) AS calendar_date
  FROM `ccbd-20260619-danieletambone.cart_dataset.raw_online_retail`
)
SELECT
  ROW_NUMBER() OVER(ORDER BY calendar_date) AS date_id_sk,
  calendar_date AS date_key,
  EXTRACT(YEAR FROM calendar_date) AS year,
  EXTRACT(QUARTER FROM calendar_date) AS quarter,
  EXTRACT(MONTH FROM calendar_date) AS month,
  EXTRACT(DAY FROM calendar_date) AS day,
  EXTRACT(DAYOFWEEK FROM calendar_date) AS day_of_week,
  FORMAT_DATE('%B', calendar_date) AS month_name
FROM 
  unique_dates;