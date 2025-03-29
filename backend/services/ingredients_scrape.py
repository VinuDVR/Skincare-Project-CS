import pandas as pd
from selenium import webdriver
from bs4 import BeautifulSoup
import time

products_df = pd.read_csv("sephora_products_labeled_men.csv")

batch_size = 500

if "Ingredients" not in products_df.columns:
    products_df["Ingredients"] = "N/A"

total_batches = len(products_df) // batch_size + (1 if len(products_df) % batch_size > 0 else 0)

driver = webdriver.Chrome()

for batch_number in range(total_batches):
    print(f"Processing batch {batch_number + 1} / {total_batches}...")

    start_indice = batch_number * batch_size
    end_indice = min ((batch_number +1) * batch_size, len(products_df))

    for index, row in products_df.iloc[start_indice:end_indice].iterrows():
        if row["Ingredients"] != "N/A":
            continue

        product_url = row["Product URL"]
        try:
            driver.get(product_url)
            time.sleep(5)

            soup = BeautifulSoup(driver.page_source, "html.parser")
            ingredients = soup.find("p", class_= "productpage-ingredients-content").text if soup.find("p", class_= "productpage-ingredients-content") else "N/A"

            products_df.at[index, "Ingredients"] = ingredients

        except Exception as e:
            print(f"Error processing {row['Name']} ({product_url}): {e}")
            products_df.at[index, "Ingredients"] = "Error"

    products_df.to_csv("sephora_products_labeled_men.csv", index = False)
    print(f"Batch {batch_number + 1} saved")

driver.quit()

print("Scarping completed and data saved.")

base_url_cleansers_men = "https://www.boots.com/mens/skincare-body?criteria.product_type=cleanser"
base_url_toners_men = "https://www.boots.com/mens/skincare-body?criteria.product_type=toner"
base_url_serums_men = "https://www.boots.com/mens/skincare-body?criteria.product_type=serum"
base_url_eyecreams_men = "https://www.boots.com/mens/skincare-body?criteria.product_type=eye+cream"
base_url_moisturizers_men = "https://www.boots.com/mens/skincare-body?criteria.product_type=moisturiser"

    "Cleansers": "https://www.johnlewis.com/browse/beauty/mens-skin-care/cleansers/_/N-a4lZ1yzjnx9",
    "Toners": "https://www.johnlewis.com/browse/beauty/mens-skin-care/toners/_/N-a4lZ1yzjnx8",
    "Serums": "https://www.johnlewis.com/browse/beauty/mens-skin-care/serums/_/N-a4lZ1yzjnwy",
    "Eye-Creams": "https://www.johnlewis.com/browse/beauty/mens-skin-care/eye-cream/_/N-a4lZlq1m",
    "Moisturisers": "https://www.johnlewis.com/browse/beauty/mens-skin-care/moisturisers/_/N-a4lZ1yzjnx6"