WITH reference_date AS (
  SELECT MAX(DATE(InvoiceDate)) AS max_date
  FROM `ccbd-20260619-danieletambone.cart_dataset.fact_sales`
),
rfm_base AS (
  SELECT 
    c.CustomerID,
    DATE_DIFF((SELECT max_date FROM reference_date), MAX(DATE(f.InvoiceDate)), DAY) AS Recency,
    COUNT(DISTINCT f.InvoiceNo) AS Frequency,
    ROUND(SUM(f.TotalAmount), 2) AS Monetary
  FROM 
    `ccbd-20260619-danieletambone.cart_dataset.fact_sales` f
  INNER JOIN 
    `ccbd-20260619-danieletambone.cart_dataset.dim_customers` c
    ON f.customer_id_sk = c.customer_id_sk
  WHERE 
    c.CustomerID != 0 
  GROUP BY 
    c.CustomerID
)
SELECT * FROM rfm_base
ORDER BY Monetary DESC, Frequency DESC;