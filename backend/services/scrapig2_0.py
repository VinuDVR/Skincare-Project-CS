import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import ElementNotInteractableException, TimeoutException
from bs4 import BeautifulSoup
import time

base_url_cleansers_men = "https://www.sephora.co.uk/skin/cleansers?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c2}/hisandhers%3E{1}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20250205T113717%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=hisandhers#inline-facets"


base_url_toners_men = "https://www.sephora.co.uk/search?q=toners+men&filter=fh_location=//c1/en_GB/$s=toners\u0020men/department%3E{skincare}/!brand={a70}/%26fh_view_size=40%26customer-country=GB%26site_id=79%26site_area=search%26refsearch=toners%5Cu0020men%26device=desktop%26fh_refview=search%26fh_reffacet=department#inline-facets"


base_url_serums_men = "https://www.sephora.co.uk/search?q=serums+men&filter=fh_location=//c1/en_GB/$s=serums\u0020men/department%3E{skincare}/!brand={a70}/%26fh_view_size=40%26customer-country=GB%26site_id=79%26site_area=search%26refsearch=serums%5Cu0020men%26device=desktop%26fh_refview=search%26fh_reffacet=department#inline-facets"


base_url_eyecreams_men = "https://www.sephora.co.uk/search?q=eye+creams+men"


base_url_moisturizers_men = "https://www.sephora.co.uk/skin/moisturisers?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c1}/hisandhers%3E{1}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20250205T111218%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=hisandhers#inline-facets"

def scrape_category(driver, url, category_label, price_category):
    driver.get(url)
    time.sleep(3)

    products = []

    while True:
        soup = BeautifulSoup(driver.page_source, "html.parser")

        product_elements = soup.find_all("div", class_="Product")

        for product in product_elements:
            brand = product.find("div", class_="brand").text if product.find("div", class_="brand") else "N/A"
            name = product.find("div", class_="productName").text if product.find("div", class_="productName") else "N/A"
            product_url = "https://www.sephora.co.uk" + product.find("a")["href"]
            price_integer = product.find("span", class_="Price-integer").text if product.find("span", class_="Price-integer") else "0"
            price_decimal = product.find("span", class_="Price-decimal").text if product.find("span", class_="Price-decimal") else "00"
            price = f"{price_integer}{price_decimal}"
            rating = product.find("span", class_="Rating-average").text if product.find("span", class_="Rating-average") else "N/A"
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
                EC.visibility_of_element_located((By.CSS_SELECTOR, "div.eba-component.loadMoreContainer"))
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
df.to_csv("test1.csv", index=False)
print("All products saved to sephora_products_labeled.csv")

driver.quit()
