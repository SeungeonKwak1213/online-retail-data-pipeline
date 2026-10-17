import pandas as pd

df = pd.read_excel("data/Online Retail.xlsx")

print(df.head())
print(df.shape)
print(df.info())
print(df.isnull().sum())
