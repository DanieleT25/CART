import os
import pandas as pd

def clean_retail_data():
    raw_path = os.path.join('data', 'online_retail_raw.csv')
    output_path = os.path.join('data', 'online_retail_clean.csv')
    
    if not os.path.exists(raw_path):
        print(f"[ERROR] The raw file {raw_path} does not exist! Please run: python3 src/download_data.py first.")
        return

    print(f"[ETL] Reading local raw file from: {raw_path}...")
    df = pd.read_csv(raw_path)
    total_initial_rows = len(df)
    
    print("---------- Starting Data Quality Pipeline ----------")
    
    # 1. Handling Anonymous Users (Preserving revenue!)
    null_customers_count = df['CustomerID'].isnull().sum()
    df['CustomerID'] = df['CustomerID'].fillna(0).astype(int)
    print(f" -> Handled {null_customers_count} anonymous records. Converted to CustomerID = 0.")

    # 2. Data type casting for BigQuery compatibility
    df['InvoiceNo'] = df['InvoiceNo'].astype(str)
    df['StockCode'] = df['StockCode'].astype(str)
    df['Description'] = df['Description'].fillna('').astype(str)
    print(" -> Data types for InvoiceNo, StockCode, and Description normalized to strings.")

    # Safe formatting for BigQuery TIMESTAMP (YYYY-MM-DD HH:MM:SS)
    df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate']).dt.strftime('%Y-%m-%d %H:%M:%S')
    print(" -> InvoiceDate converted to a BigQuery-compatible TIMESTAMP format.")

    # 3. Surgical filtering of active transactions (Excludes quantity <= 0 and zero-price records)
    df_clean = df[(df['UnitPrice'] > 0) & (df['Quantity'] > 0)].copy()
    removed_rows = total_initial_rows - len(df_clean)
    print(f" -> Removed {removed_rows} anomalous rows (negative/zero prices, returns, or null quantities).")

    # 4. Final ETL Traceability Report
    print("\n---------- Final ETL Report ----------")
    print(f"Rows in the final clean CSV: {len(df_clean)}")
    print(f"Percentage of discarded rows: {(removed_rows / total_initial_rows) * 100:.2f}%")
    
    # Saving the file ready for Google Cloud Storage
    df_clean.to_csv(output_path, index=False, encoding='utf-8')
    print(f"[INFO] Clean file successfully saved to: {output_path}")

if __name__ == '__main__':
    clean_retail_data()