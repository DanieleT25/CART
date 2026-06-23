-- Creation of the historical dimensional table for Products (SCD Type 2) with Categorization
CREATE OR REPLACE TABLE `ccbd-20260619-danieletambone.cart_dataset.dim_products_scd` AS
WITH unique_product_states AS (
  SELECT
    StockCode, Description, UnitPrice,
    MIN(InvoiceDate) AS state_start_date,
    MAX(InvoiceDate) AS state_end_date
  FROM `ccbd-20260619-danieletambone.cart_dataset.raw_online_retail`
  GROUP BY StockCode, Description, UnitPrice
),
historical_chains AS (
  SELECT
    StockCode, Description, UnitPrice,
    state_start_date AS valid_from,
    LEAD(state_start_date) OVER(PARTITION BY StockCode ORDER BY state_start_date) AS next_state_start
  FROM unique_product_states
)
SELECT
  ROW_NUMBER() OVER(ORDER BY StockCode, valid_from) AS product_id_sk,
  StockCode,
  Description,
  UnitPrice,
  CASE 
    WHEN StockCode IN ('M', 'D', 'POST', 'CRUK', 'DOT', 'B', 'BANK CHARGES', 'AMAZONFEE', 'S') THEN 'Service/Administration'
    ELSE 'Physical Product'
  END AS product_type,
  valid_from,
  COALESCE(next_state_start, CAST('2099-12-31' AS TIMESTAMP)) AS valid_to,
  CASE WHEN next_state_start IS NULL THEN TRUE ELSE FALSE END AS is_current
FROM 
  historical_chains;