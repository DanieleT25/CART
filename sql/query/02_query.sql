SELECT
    c.country,
    COUNT(DISTINCT f.InvoiceNo) AS total_orders,
    ROUND(SUM(f.TotalAmount), 2) AS total_revenue,
    ROUND(SUM(f.TotalAmount) / COUNT(DISTINCT f.InvoiceNo), 2) AS average_order_value
FROM
    `ccbd-20260619-danieletambone.cart_dataset.fact_sales` f
    INNER JOIN
    `ccbd-20260619-danieletambone.cart_dataset.dim_customers` c
    ON f.customer_id_sk = c.customer_id_sk
GROUP BY
    country
ORDER BY
    total_revenue DESC;