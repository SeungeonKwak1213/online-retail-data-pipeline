import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

url = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
engine = create_engine(url)

with engine.connect() as conn:
    print(conn.execute(text("SELECT current_database()")).scalar())



df = pd.read_csv(
    'data/processed/Online_Retail_clean.csv',
    parse_dates=['InvoiceDate']
    )

df.columns = df.columns.str.lower()

df['customerid'] = df['customerid'].astype('Int64')

with engine.begin() as conn:
    conn.execute(text("TRUNCATE TABLE online_retail"))

df.to_sql(
    'online_retail',
    engine,
    if_exists='append',
    index=False,
    chunksize=10000,
    method='multi'
)

with engine.connect() as conn:
    count = conn.execute(text("SELECT COUNT(*) FROM online_retail")).scalar()
    print('rows loaded:', count)