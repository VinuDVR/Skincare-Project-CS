import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import ElementNotInteractableException, TimeoutException
from bs4 import BeautifulSoup
import time

base_url_cleansers_men = "https://www.lookfantastic.com/c/health-beauty/men/face/cleansers/"


base_url_toners_men = "https://www.lookfantastic.com/c/health-beauty/men/face/toners/"


base_url_serums_men = "https://www.lookfantastic.com/c/health-beauty/men/face/serums/"


base_url_eyecreams_men = "https://www.lookfantastic.com/c/health-beauty/men/face/eye-care/"


base_url_moisturizers_men = "https://www.lookfantastic.com/c/health-beauty/men/face/moisturisers/"

def scrape_category(driver, url, category_label, price_category):
    driver.get(url)
    time.sleep(3)

    products = []

    while True:
        soup = BeautifulSoup(driver.page_source, "html.parser")

        product_elements = soup.find_all("div", class_="group flex flex-col justify-start h-full w-full")

        for product in product_elements:
            brand = product.find("div", class_="brand").text if product.find("div", class_="brand") else "N/A"
            name = product.find("div", class_="h-full product-data").text if product.find("div", class_="h-full product-data") else "N/A"
            product_url = "https://www.lookfantastic.com" + product.find("a")["href"]
            price = product.find("span", class_="Price").text if product.find("span", class_="Price") else "0"
            #price_integer = product.find("span", class_="Price-integer").text if product.find("span", class_="Price-integer") else "0"
            #price_decimal = product.find("span", class_="Price-decimal").text if product.find("span", class_="Price-decimal") else "00"
            #price = f"{price_integer}{price_decimal}"
            rating = product.find("p", class_="sr-only").text if product.find("p", class_="sr-only") else "N/A"
            image_url = product.find("img")["src"] if product.find("img") else "N/A"

            products.append({
                "Brand": brand,
                "Name": name,
                "Price": price,
                "Rating": rating,
                "Product URL": product_url,
                "Image URL": image_url,
                "Category": category_label,
                "Price Category": price_category,
                "Gender": "Mens"
            })

        try:
            load_more_button = WebDriverWait(driver, 10).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "a.next-page-button flex items-center text-black"))
            )

            driver.execute_script("arguments[0].scrollIntoView(true);", load_more_button)
            time.sleep(1)
            load_more_button.click()
            time.sleep(3)
        except:
            print(f"All products loaded for {category_label}")
            break

    return products

driver = webdriver.Chrome()

all_products = []

all_products.extend(scrape_category(driver, base_url_cleansers_men, "Cleansers", "No range"))

all_products.extend(scrape_category(driver, base_url_toners_men, "Toners", "No range"))

all_products.extend(scrape_category(driver, base_url_serums_men, "Serums", "No range"))

all_products.extend(scrape_category(driver, base_url_eyecreams_men, "Eye-Creams", "No range"))

all_products.extend(scrape_category(driver, base_url_moisturizers_men, "Moisturizers", "No range"))

df = pd.DataFrame(all_products)
df.to_csv("boots_mens_skincare.csv", index=False)
print("All products saved to sephora_products_labeled.csv")

driver.quit()
