-- Create the dimensional table for Customers
CREATE OR REPLACE TABLE `ccbd-20260619-danieletambone.cart_dataset.dim_customers` AS
WITH unique_customers AS (
  SELECT
    CustomerID,
    MAX(Country) AS Country
  FROM 
    `ccbd-20260619-danieletambone.cart_dataset.raw_online_retail`
  GROUP BY 
    CustomerID
)
SELECT
  -- Generated surrogate key as an integer
  ROW_NUMBER() OVER(ORDER BY CustomerID) AS customer_id_sk,
  
  CustomerID, -- keep the natural key for future lookups 
  Country
FROM 
  unique_customers;