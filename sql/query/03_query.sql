SELECT 
  FORMAT_DATE('%A', d.date_key) AS day_of_week,
  
  CASE 
    WHEN EXTRACT(HOUR FROM f.InvoiceDate) BETWEEN 6 AND 12 THEN '1 - Morning (06:00 am - 12:59 pm)'
    WHEN EXTRACT(HOUR FROM f.InvoiceDate) BETWEEN 13 AND 17 THEN '2 - Afternoon (01:00 pm - 05:59 pm)'
    WHEN EXTRACT(HOUR FROM f.InvoiceDate) BETWEEN 18 AND 22 THEN '3 - Evening (06:00 pm - 10:59 pm)'
    ELSE '4 - Night (11:00 pm - 05:59 am)'
  END AS time_of_day,
  
  COUNT(DISTINCT f.InvoiceNo) AS total_orders

FROM 
  `ccbd-20260619-danieletambone.cart_dataset.fact_sales` f
INNER JOIN 
  `ccbd-20260619-danieletambone.cart_dataset.dim_date` d
  ON f.date_id_sk = d.date_id_sk

GROUP BY 
  day_of_week, 
  time_of_day
ORDER BY 
  total_orders DESC;