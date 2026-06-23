from pathlib import Path
import pandas as pd
from IPython.display import Markdown, display
from google.cloud import bigquery
from sympy import preview

SQL_DIR = Path('sql')
SQL_DIR.mkdir(exist_ok=True)

def load_sql(name):
    """Read the SQL file from the local folder."""
    return (SQL_DIR / name).read_text()

def run_query(client, sql, max_gb=2.0, preview=True):
    """Executes the query with cost controls and returns a Pandas DataFrame."""
    if preview:
        dry = client.query(sql, location='europe-west8', job_config=bigquery.QueryJobConfig(dry_run=True, use_query_cache=False))
        print(f'Dry-run: This query will process {dry.total_bytes_processed / 1e9:.3f} GB')
    
    cfg = bigquery.QueryJobConfig(maximum_bytes_billed=int(max_gb * 1e9))
    return client.query(sql, location='europe-west8', job_config=cfg).to_dataframe()

def show_and_run(client, name, max_gb=2.0, preview=True):
    """Prints the SQL code for documentation and then executes it."""
    sql = load_sql(name)
    display(Markdown(f"**Execution of file: `sql/{name}`**\n\n```sql\n{sql}\n```"))
    return run_query(client, sql, max_gb=max_gb, preview=preview)