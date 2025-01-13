import pandas as pd

df = pd.read_csv("sephora_products_labeled.csv")

#duplicates = df[df.duplicated()]
#print("Duplicates: ", duplicates)
#df.drop_duplicates()

df.dropna(subset = ["Rating", "Ingredients"], inplace = True)

print("Missing values per column: \n", df.isnull().sum())

df["Rating"] = df["Rating"].astype(str).str.strip()  
df["Rating"] = df["Rating"].str.replace(r"[^\d.]", "", regex=True)  
df["Rating"] = pd.to_numeric(df["Rating"], errors='coerce')
#df["Ingredients"] = df["Ingredients"].astype(str)

print(df["Rating"])

print(df["Ingredients"])

df.to_csv("preprocessed_skincare_products.csv", index=False)

print("Preprocessing complete. Cleaned dataset saved.")