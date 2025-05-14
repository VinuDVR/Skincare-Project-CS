from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import ElementNotInteractableException, TimeoutException
from bs4 import BeautifulSoup
import time
import requests
import pandas as pd

driver = webdriver.Chrome()

base_url = "https://www.sephora.co.uk/skin/cleansers"
driver.get(base_url)

time.sleep(10)


while True:
    try:
        
        load_more_button = WebDriverWait(driver, 10).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "div.eba-component.loadMoreContainer"))
            )

        
        driver.execute_script("arguments[0].scrollIntoView(true);", load_more_button)
        time.sleep(1)
        load_more_button.click()
        
        
        time.sleep(3)
        
    except (ElementNotInteractableException, TimeoutException):
            
            print("Load more button is no longer interactable or visible.")
            break

soup = BeautifulSoup(driver.page_source, "html.parser")
driver.quit()

product_elements = soup.find_all("div", class_ = "Product")

product_data = []

for product in product_elements:
    try:
        brand = product.find("div", class_ = "brand" ).text if product.find("div", class_ = "brand") else "N/A"
        
        name = product.find("div", class_ = "productName" ).text if product.find("div", class_ = "productName") else "N/A"

        product_url = "https://www.sephora.co.uk" + product.find("a")["href"]

        price_integer = product.find("span", class_="Price-integer").text if product.find("span", class_="Price-integer") else "0"
        price_decimal = product.find("span", class_="Price-decimal").text if product.find("span", class_="Price-decimal") else "00"

        price = f"{price_integer}.{price_decimal}"

        rating = product.find("span", class_ = "rating").text if product.find("span", class_ = "Rating-average") else "N/A"

        image_url = product.find("img")["src"] if product.find("img") else "N/A"

        
        product_data.append({
            "Brand": brand,
            "Name": name,
            "Price": price,
            "Rating": rating,
            "Image URL": image_url,
            "Product URL": product_url
        })

    except Exception as e:
        print(f"An error occurred: {e}")

df = pd.DataFrame(product_data)
df.to_csv("sephora_products.csv", index=False)
print("Data saved to sephora_products.csv")

