import pandas as pd

df = pd.read_excel('data/Online Retail.xlsx')


df['is_cancelled'] = df['InvoiceNo'].astype(str).str.startswith('C')
print('start:', len(df))

df = df[df['UnitPrice'] > 0]
print('after price:', len(df))


df = df[(df['is_cancelled']) | (df['Quantity'] > 0)]
print('after quantity:', len(df))
print('cancelled left:', df['is_cancelled'].sum())

df = df.drop_duplicates()
print('after duplicates:', len(df))

df['Description'] = df['Description'].str.strip()

df['TotalPrice'] = df['Quantity'] * df['UnitPrice']

sales = df[(~df['is_cancelled']) & (df['CustomerID'].notna())]
customer = sales.groupby('CustomerID')['TotalPrice'].sum()
total = sales['TotalPrice'].sum()
result = (customer/total).sort_values(ascending=False)*100
vip = result[result>1].index
df['VIP_Customer'] = df['CustomerID'].isin(vip)

df.to_csv('data/processed/Online_Retail_clean.csv', index=False)
print(df.shape)
