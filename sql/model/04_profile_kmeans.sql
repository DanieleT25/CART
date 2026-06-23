SELECT 
  Cluster_Segment,
  COUNT(CustomerID) AS customer_count,
  ROUND(AVG(Recency), 0) AS avg_recency_days,
  ROUND(AVG(Frequency), 1) AS avg_frequency_orders,
  ROUND(AVG(Monetary), 2) AS avg_monetary_gbp
FROM {DATASET}.dim_customers_enriched
GROUP BY Cluster_Segment
ORDER BY Cluster_Segment;