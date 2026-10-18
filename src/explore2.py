import pandas as pd
df = pd.read_excel("data/Online Retail.xlsx")

# Cancellation
df['is_cancelled'] = df['InvoiceNo'].astype(str).str.startswith('C')
print('cancelled sum:', df['is_cancelled'].sum())

# Error
df['error_price'] = (df['UnitPrice']<=0)
print('error price:',df['error_price'].sum())
df['error_quantity'] = ~df['is_cancelled'] & (df['Quantity']<=0)
print('error quantity: ', df['error_quantity'].sum())

# duplicate
print("duplicate: ", df.duplicated().sum())

# description error
df['description_error'] = (df['Description'].astype(str).str.startswith('?') | df['Description'].astype(str).str.startswith(' '))
print('description error: ', df['description_error'].sum())

# date range / num of country
print(df["InvoiceDate"].min(), "~", df["InvoiceDate"].max())
print("number of country:", df["Country"].nunique())