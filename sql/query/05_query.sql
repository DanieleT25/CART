WITH customer_cohort AS (
  -- 1. Find the month of the FIRST purchase for each customer (Their Cohort)
  SELECT 
    c.CustomerID,
    DATE_TRUNC(MIN(DATE(f.InvoiceDate)), MONTH) AS cohort_month
  FROM 
    `ccbd-20260619-danieletambone.cart_dataset.fact_sales` f
  INNER JOIN 
    `ccbd-20260619-danieletambone.cart_dataset.dim_customers` c
    ON f.customer_id_sk = c.customer_id_sk
  WHERE 
    c.CustomerID != 0 -- Exclude anonymous (guest) customers
  GROUP BY 
    c.CustomerID
),

customer_purchases AS (
  -- 2. Extract all months in which a customer made at least one purchase
  SELECT DISTINCT
    c.CustomerID,
    DATE_TRUNC(DATE(f.InvoiceDate), MONTH) AS purchase_month
  FROM 
    `ccbd-20260619-danieletambone.cart_dataset.fact_sales` f
  INNER JOIN 
    `ccbd-20260619-danieletambone.cart_dataset.dim_customers` c
    ON f.customer_id_sk = c.customer_id_sk
  WHERE 
    c.CustomerID != 0
)

-- 3. Join the two tables to calculate the months passed since the first purchase
SELECT 
  FORMAT_DATE('%Y-%m', cc.cohort_month) AS acquisition_month,
  
  -- Calculate the retention month index (Month 0 = first purchase, Month 1 = next month, etc.)
  DATE_DIFF(cp.purchase_month, cc.cohort_month, MONTH) AS retention_month_index,
  
  -- Count how many unique customers of that cohort were active in that specific month
  COUNT(DISTINCT cp.CustomerID) AS active_customers

FROM 
  customer_cohort cc
INNER JOIN 
  customer_purchases cp
  ON cc.CustomerID = cp.CustomerID

GROUP BY 
  acquisition_month, 
  retention_month_index
ORDER BY 
  acquisition_month ASC, 
  retention_month_index ASC;