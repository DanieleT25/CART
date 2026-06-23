-- Creation of the central Fact Table for sales with all surrogate keys
CREATE OR REPLACE TABLE `ccbd-20260619-danieletambone.cart_dataset.fact_sales` AS
SELECT
  f.InvoiceNo,
  f.InvoiceDate,
  f.Quantity,
  f.UnitPrice,
  (f.Quantity * f.UnitPrice) AS TotalAmount,
  c.customer_id_sk,
  p.product_id_sk,
  d.date_id_sk
FROM 
  `ccbd-20260619-danieletambone.cart_dataset.raw_online_retail` f
-- Lookup Clienti
LEFT JOIN 
  `ccbd-20260619-danieletambone.cart_dataset.dim_customers` c 
  ON f.CustomerID = c.CustomerID
-- Lookup Prodotti (SCD2)
LEFT JOIN 
  `ccbd-20260619-danieletambone.cart_dataset.dim_products_scd` p 
  ON f.StockCode = p.StockCode
  AND f.InvoiceDate >= p.valid_from 
  AND f.InvoiceDate < p.valid_to
-- Lookup Data
LEFT JOIN 
  `ccbd-20260619-danieletambone.cart_dataset.dim_date` d
  ON DATE(f.InvoiceDate) = d.date_key;