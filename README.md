# Online Retail Data Pipeline

An end-to-end data project: clean a real-world transaction dataset with Python, load it into PostgreSQL, and answer business questions with SQL.

# Overview

The project uses the [UCI Online Retail dataset](https://archive.ics.uci.edu/dataset/352/online%2Bretail), which contains transactions from a UK-based online retailer between 2010-12-01 and 2011-12-09 (541,909 rows, 38 countries).

Goals

1. Clean the raw data (missing values, cancellations, invalid prices, duplicates)
2. Build a repeatable ETL pipeline in Python
3. Store the cleaned data in PostgreSQL
4. Analyze revenue, top products, countries, cancellations, and VIP customers with SQL

# Tech Stack

Python (pandas, SQLAlchemy, psycopg2, python-dotenv), PostgreSQL, SQL, Git/GitHub

# Pipeline

```
Online Retail.xlsx -> clean.py -> cleaned CSV -> load.py -> PostgreSQL -> analysis.sql
     (raw)            (transform)                (load)                     (insights)
```

# Project Structure

```
.
├── data/
│   ├── Online Retail.xlsx   # raw data (not tracked by Git)
│   └── processed/           # cleaned CSV (not tracked by Git)
├── sql/
│   ├── schema.sql           # table definition
│   └── analysis.sql         # analysis queries
├── src/
│   ├── explore.py           # first look at the data
│   ├── explore2.py          # counts of cancellations, invalid values, duplicates
│   ├── clean.py             # cleaning and feature columns
│   ├── load.py              # load CSV into PostgreSQL
│   └── test_db.py           # check database connection
├── requirements.txt
└── README.md
```


# Data Cleaning

- Raw data: 541,909 rows
- Removed rows with `UnitPrice <= 0`: 2,517 rows (539,392 remaining)
- Removed non-cancelled rows with `Quantity <= 0`: 0 additional rows (already removed by the price filter)
- Removed duplicate rows: 5,263 rows (534,129 remaining)
- Final: 534,129 rows, 7,780 fewer than the raw data (about 1.4%)

# Decisions and reasoning

- **Cancelled orders are kept, not deleted.** Invoices starting with `C` (9,288 rows) are flagged with an `is_cancelled` column. They have negative quantities, so summing them subtracts cancelled amounts and gives net revenue.
- **Missing `CustomerID` (about 25% of rows) is kept.** Revenue, product, and country analysis does not need it. Only customer-level analysis excludes these rows.
- **Rows with missing `Description` disappeared with the price filter.** They were internal adjustment records with a price of 0.
- **Descriptions are trimmed.** Some had leading or trailing spaces, which would split the same product into two groups.
- **Derived columns:** `TotalPrice = Quantity * UnitPrice`, and `VIP_Customer`.

# Database

The `online_retail` table is defined in `sql/schema.sql` with explicit types and `NOT NULL` constraints on the key columns. `CustomerID` stays nullable because of the missing values above.

`load.py` truncates the table before loading, so running it repeatedly always produces the same 534,129 rows.

# Analysis

All figures are in pounds sterling. Queries are in `sql/analysis.sql`.

# Definitions

- Revenue is net of cancellations (cancelled rows are included with negative values). Product rankings exclude non-product codes such as postage (`DOT`) and manual entries (`M`).

# 1. Monthly revenue 

- Highest month: 2011-11 with £1,456,145.80
- Lowest complete month: 2011-04 with £492,367.84
- 2011-12 has the lowest total, but it only contains data up to Dec 9, so it is not comparable to the other months.

# 2. Top 3 products by net revenue

| Stock code | Product | Units | Revenue |
|---|---|---|---|
| 22423 | REGENCY CAKESTAND 3 TIER | 12,996 | £164,459.49 |
| 47566 | PARTY BUNTING | 18,006 | £98,243.88 |
| 85123A | WHITE HANGING HEART T-LIGHT HOLDER | 35,063 | £97,838.45 |

# 3. Revenue by country

| Country | Revenue |
|---|---|
| United Kingdom | £8,189,252.30 |
| Netherlands | £284,661.54 |
| EIRE | £262,993.38 |

The United Kingdom accounts for the vast majority of revenue.

# 4. Cancellation rate by product

Cancellation rate = orders with a cancellation invoice / all orders containing the product, counted by distinct invoice number. Only products with at least 100 orders are included, to avoid noisy rates from tiny samples.

| Stock code | Product | Orders | Cancelled | Rate |
|---|---|---|---|---|
| 22198 | LARGE POPCORN HOLDER | 101 | 15 | 14.85% |
| 37449 | CERAMIC CAKE STAND + HANGING CAKES | 179 | 25 | 13.97% |
| 21527 | RED RETROSPOT TRADITIONAL TEAPOT | 165 | 21 | 12.73% |

# 5. VIP customers

A VIP is a customer who contributes at least 1% of revenue among identified customers, excluding cancelled invoices. I first tried 5%, but no customer reached it, so the threshold was lowered to 1%. That gives 8 VIP customers, with about £1.38M combined revenue.

| CustomerID | Revenue |
|---|---|
| 14646 | £280,206.02 |
| 18102 | £259,657.30 |
| 17450 | £194,390.79 |
| 16446 | £168,472.50 |
| 14911 | £143,711.17 |
| 12415 | £124,914.53 |
| 14156 | £117,210.08 |
| 17511 | £91,062.38 |

The VIP query uses revenue excluding cancelled invoices, to match how the VIP flag is defined in `clean.py`.

# How to Run

1. Download the dataset from UCI and place `Online Retail.xlsx` in `data/`.
2. Create the environment and install dependencies:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```
3. Create a PostgreSQL database named `online_retail` and run `sql/schema.sql` in it.
4. Create a `.env` file in the project root:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=online_retail
   DB_USER=postgres
   DB_PASSWORD=your_password
   ```
5. Run the pipeline:
   ```bash
   mkdir -p data/processed
   python3 src/clean.py
   python3 src/load.py
   ```
6. Run the queries in `sql/analysis.sql` with pgAdmin or `psql`.

## Limitations

- 2011-12 is an incomplete month (data ends on Dec 9).
- Cancellation invoices are not linked to their original orders, so the cancellation rate means "share of orders that have a cancellation record", not an exact return rate.
- About 25% of rows have no `CustomerID`, so customer analysis (VIP) covers identified customers only.
- Revenue figures are net of cancellations, while the VIP query excludes cancelled invoices. The two bases are documented above.
- The data covers a single retailer and one year, so it cannot show long-term seasonality.