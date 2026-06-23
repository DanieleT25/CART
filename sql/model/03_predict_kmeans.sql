CREATE OR REPLACE TABLE {DATASET}.dim_customers_enriched AS
SELECT
  CustomerID,
  Recency,
  Frequency,
  Monetary,
  CENTROID_ID AS Cluster_Segment
FROM ML.PREDICT(
  MODEL {DATASET}.rfm_clusters,
  (
    SELECT 
      CustomerID,
      DATE_DIFF((SELECT MAX(DATE(InvoiceDate)) FROM {DATASET}.raw_online_retail), MAX(DATE(InvoiceDate)), DAY) AS Recency,
      COUNT(DISTINCT InvoiceNo) AS Frequency,
      ROUND(SUM(Quantity * UnitPrice), 2) AS Monetary
    FROM 
      {DATASET}.raw_online_retail
    WHERE 
      CustomerID != 0
    GROUP BY 
      CustomerID
  )
)
ORDER BY Cluster_Segment;