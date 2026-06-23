# Analytical Queries

This directory contains the advanced SQL queries used to extract actionable business insights from the BigQuery Star Schema. These scripts serve as the analytical core of the C.A.R.T. project, powering the interactive Looker Studio dashboard and providing the foundational datasets for the Machine Learning models.

## Query Inventory

* **`01_query.sql` - Sales Trend Analysis**
  Aggregates total revenue and order volume on a monthly basis to track high-level business growth and seasonality.

* **`02_query.sql` - Geographic Performance**
  Evaluates market penetration by calculating Total Orders, Total Revenue, and Average Order Value (AOV) broken down by country.

* **`03_query.sql` - Temporal Shopping Habits**
  Analyzes customer behavior by mapping order distribution across days of the week and specific time brackets (Morning, Afternoon, Evening, Night).

* **`04_query.sql` - RFM Customer Segmentation**
  Computes the Recency, Frequency, and Monetary (RFM) metrics for each customer. This query provides the exact dataset required for the K-Means clustering algorithm. *(Note: A variant with `RAND() < 0.20`).*

* **`05_query.sql` - Cohort Analysis & Retention**
  A complex query utilizing Window Functions and Self-Joins to track customer retention. It calculates the number of active users month-over-month based on their initial acquisition cohort.

* **`06_query.sql` - Pareto Analysis (Top Sellers)**
  Identifies the most profitable physical products and calculates their cumulative percentage contribution to the global revenue, validating the 80/20 rule.

## Usage

All queries are written in **Google Standard SQL**. They can be executed directly within the BigQuery Console or imported as *Custom SQL Data Sources* in Looker Studio for live visualization.