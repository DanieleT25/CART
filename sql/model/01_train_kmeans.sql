CREATE OR REPLACE MODEL {DATASET}.rfm_clusters
OPTIONS(
  model_type='KMEANS',
  num_clusters=3,
  standardize_features=TRUE
) AS
SELECT 
  DATE_DIFF((SELECT MAX(DATE(InvoiceDate)) FROM {DATASET}.raw_online_retail), MAX(DATE(InvoiceDate)), DAY) AS Recency,
  COUNT(DISTINCT InvoiceNo) AS Frequency,
  ROUND(SUM(Quantity * UnitPrice), 2) AS Monetary
FROM 
  {DATASET}.raw_online_retail
WHERE 
  CustomerID != 0
GROUP BY 
  CustomerID;