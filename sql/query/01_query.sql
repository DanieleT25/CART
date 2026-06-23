SELECT
  FORMAT_DATE('%Y-%m', d.date_key) AS month_year,
  COUNT(DISTINCT f.InvoiceNo) AS total_orders,
  ROUND(SUM(f.TotalAmount), 2) AS total_revenue

FROM 
  `ccbd-20260619-danieletambone.cart_dataset.fact_sales` f
INNER JOIN 
  `ccbd-20260619-danieletambone.cart_dataset.dim_date` d
  ON f.date_id_sk = d.date_id_sk

GROUP BY 
  month_year
ORDER BY 
  month_year ASC;