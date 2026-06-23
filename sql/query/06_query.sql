WITH product_revenue AS (
  -- 1. Calculate the total revenue for each physical product
  SELECT 
    p.StockCode,
    p.Description AS product_name,
    SUM(f.TotalAmount) AS total_revenue
  FROM 
    `ccbd-20260619-danieletambone.cart_dataset.fact_sales` f
  INNER JOIN 
    `ccbd-20260619-danieletambone.cart_dataset.dim_products_scd` p
    ON f.product_id_sk = p.product_id_sk
  WHERE 
    p.product_type = 'Physical Product'
  GROUP BY 
    p.StockCode, 
    product_name
),

cumulative_data AS (
  -- 2. Use Window Functions to calculate the running cumulative sum and the global total
  SELECT 
    product_name,
    total_revenue,
    -- Running sum: current row + all preceding rows
    SUM(total_revenue) OVER(ORDER BY total_revenue DESC) AS cumulative_revenue,
    -- Global sum: total of all products to calculate the percentage
    SUM(total_revenue) OVER() AS global_revenue
  FROM 
    product_revenue
)

-- 3. Calculate the final percentage
SELECT 
  product_name,
  ROUND(total_revenue, 2) AS total_revenue,
  ROUND(cumulative_revenue, 2) AS cumulative_revenue,
  -- Calculation of the cumulative percentage (e.g., 15.5%)
  ROUND((cumulative_revenue / global_revenue) * 100, 2) AS cumulative_percentage
FROM 
  cumulative_data
ORDER BY 
  total_revenue DESC
LIMIT 50; -- Limit to the top 50 to display the absolute "Best Sellers"