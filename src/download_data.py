import os
import pandas as pd
import argparse
from ucimlrepo import fetch_ucirepo 

def download_raw_data(force=False):
    """
    Downloads the original Online Retail dataset and saves it locally.
    If the file already exists, it skips the download unless force=True.
    """
    os.makedirs('data', exist_ok=True)
    raw_path = os.path.join('data', 'online_retail_raw.csv')
    
    if os.path.exists(raw_path) and not force:
        print(f"[INFO] Raw file already exists at: {raw_path}")
        print("[INFO] Skipping download. To force it, use: python3 src/download_data.py --force")
        return
        
    print("[DOWNLOAD] File not found or download forced. Connecting to UCI Repository...")
    print("(This operation may take a few seconds...)")
    
    online_retail = fetch_ucirepo(id=352)
    df_raw = online_retail.data.original
    
    print(f"[DOWNLOAD] Successfully completed. Rows downloaded: {len(df_raw)}")
    
    df_raw.to_csv(raw_path, index=False, encoding='utf-8')
    print(f"[INFO] Raw dataset saved to: {raw_path}")

if __name__ == '__main__':
    # Configure the command-line argument parser
    parser = argparse.ArgumentParser(description="Download the Online Retail dataset.")
    
    # Add the --force flag (True if present in the command, False otherwise)
    parser.add_argument('--force', action='store_true', help="Force the download even if the file already exists")
    
    args = parser.parse_args()
    
    # Pass the flag value to the function
    download_raw_data(force=args.force)