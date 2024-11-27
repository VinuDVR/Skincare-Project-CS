import pandas as pd
from selenium import webdriver
from bs4 import BeautifulSoup
import time

products_df = pd.read_csv("sephora_products.csv")

driver = webdriver.Chrome()

ingredients_data = {}

for index, row in products_df.iterrows():
    product_url = row["Product URL"]
    driver.get(product_url)
    time.sleep(5)

    soup = BeautifulSoup(driver.page_source, "html.parser")
    ingredients = soup.find("p", class_= "productpage-ingredients-content").text if soup.find("p", class_= "productpage-ingredients-content") else "N/A"

    ingredients_data[row["Name"]] = ingredients

driver.quit()

products_df["Ingredients"] = products_df["Name"].map(ingredients_data)
products_df.to_csv("sephora_products.csv", index=False)
print("Ingredients added and data saved to sephora_products.csv")