SELECT 
    f.InvoiceNo,
    f.InvoiceDate,
    f.Quantity,
    f.UnitPrice,
    f.TotalAmount,
    c.CustomerID,
    c.Country,
    ce.Cluster_Segment,
    ce.Recency,
    ce.Frequency,
    ce.Monetary,
    p.StockCode,
    p.Description,
    p.product_type,
    d.year,
    d.month,
    d.month_name,
    d.day_of_week

FROM `ccbd-20260619-danieletambone.cart_dataset.fact_sales` f
LEFT JOIN `ccbd-20260619-danieletambone.cart_dataset.dim_customers` c 
    ON f.customer_id_sk = c.customer_id_sk
LEFT JOIN `ccbd-20260619-danieletambone.cart_dataset.dim_customers_enriched` ce 
    ON c.CustomerID = ce.CustomerID
LEFT JOIN `ccbd-20260619-danieletambone.cart_dataset.dim_products_scd` p 
    ON f.product_id_sk = p.product_id_sk
LEFT JOIN `ccbd-20260619-danieletambone.cart_dataset.dim_date` d 
    ON f.date_id_sk = d.date_id_sk