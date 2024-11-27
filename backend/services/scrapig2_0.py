import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import ElementNotInteractableException, TimeoutException
from bs4 import BeautifulSoup
import time

base_url_cleansers_budget = "https://www.sephora.co.uk/skin/cleansers?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c2}/brand%3E{a1373;a1662;a1158;a1198;a1623;a1871;a1896;a1606;a2175;a792;a5189}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241117T195444%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_cleansers_mid = "https://www.sephora.co.uk/skin/cleansers?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c2}/brand%3E{a37;a1173;a1230;a1539;a823;a241;a6668;a1119;a3503;a4206;a4357;a5479;a5581;a243;a3739;a5697;a6182}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241117T195744%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_cleansers_high = "https://www.sephora.co.uk/skin/cleansers?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c2}/brand%3E{a49;a64;a159;a1663;a2179;a3502;a240;a5958;a5960;a5732;a5640}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241117T200107%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"

base_url_toners_budget = "https://www.sephora.co.uk/skin/toners?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c3}/brand%3E{a1373;a1662;a1158;a1896;a2175;a792;a5189}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T190551%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_toners_mid = "https://www.sephora.co.uk/skin/toners?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c3}/brand%3E{a37;a1173;a1230;a1539;a823;a241;a1119;a3503;a4357;a5581;a243;a3739}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T190841%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_toners_high = "https://www.sephora.co.uk/skin/toners?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c3}/brand%3E{a79;a49;a64;a159;a1663;a3502;a5732;a5640}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T191201%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"

base_url_serums_budget = "https://www.sephora.co.uk/skin/serums?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c28}/brand%3E{a1373;a1662;a1158;a1198;a1623;a1871;a1896;a2175;a792;a5189}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T194529%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_serums_mid = "https://www.sephora.co.uk/skin/serums?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c28}/brand%3E{a37;a1173;a1230;a1539;a823;a241;a6668;a1119;a3503;a4206;a4357;a5479;a5581;a243;a3739;a5697;a6182}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T194840%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_serums_high = "https://www.sephora.co.uk/skin/serums?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c28}/brand%3E{a79;a49;a64;a159;a1663;a2179;a3502;a240;a5580;a5958;a5732;a5640}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T195155%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"

base_url_eyecreams_budget = "https://www.sephora.co.uk/skin/eye-care/eye-creams?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c5}/categories%3C{c1_c1c1_c1c1c5_c1c1c5c2}/brand%3E{a1662;a1158;a40;a1623;a1896;a2175;a792;a5189}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T195542%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_eyecreams_mid = "https://www.sephora.co.uk/skin/eye-care/eye-creams?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c5}/categories%3C{c1_c1c1_c1c1c5_c1c1c5c2}/brand%3E{a37;a1173;a1230;a1539;a823;a241;a6668;a1119;a3503;a4206;a4357;a5479;a243;a3739;a5697;a6182}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T195828%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_eyecreams_high = "https://www.sephora.co.uk/skin/eye-care/eye-creams?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c5}/categories%3C{c1_c1c1_c1c1c5_c1c1c5c2}/brand%3E{a79;a49;a64;a159;a1663;a2179;a3502;a240;a5958;a5960;a5732;a5640}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T200206%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"

base_url_moisturizers_budget = "https://www.sephora.co.uk/skin/moisturisers?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c1}/brand%3E{a1373;a40;a1662;a1158;a1198;a1623;a1871;a1896;a2175;a792;a39;a5189}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T203657%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_moisturizers_mid = "https://www.sephora.co.uk/skin/moisturisers?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c1}/brand%3E{a37;a1173;a1230;a1539;a823;a241;a6668;a1119;a3503;a4206;a4357;a5479;a5581;a243;a3739;a5697;a6182}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T204003%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_moisturizers_high = "https://www.sephora.co.uk/skin/moisturisers?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c1}/brand%3E{a79;a49;a64;a159;a1663;a2179;a3502;a240;a5580;a5958;a5960;a5732;a5640}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T204239%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"

base_url_sunscreens_budget = "https://www.sephora.co.uk/skin/skincare-sun-care-sunscreen?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c38}/categories%3C{c1_c1c1_c1c1c38_c1c1c38c1}/brand%3E{a1198}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T213447%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_sunscreens_mid = "https://www.sephora.co.uk/skin/skincare-sun-care-sunscreen?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c38}/categories%3C{c1_c1c1_c1c1c38_c1c1c38c1}/brand%3E{a37;a1173;a1230;a1539;a241;a6668;a4357;a5581;a243}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T213917%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"
base_url_sunscreens_high = "https://www.sephora.co.uk/skin/skincare-sun-care-sunscreen?filter=fh_location=//c1/en_GB/categories%3C{c1_c1c1}/categories%3C{c1_c1c1_c1c1c38}/categories%3C{c1_c1c1_c1c1c38_c1c1c38c1}/brand%3E{a79;a64;a159;a1663;a5580;a5732}/!brand={a70}/!restricted=1/%26fh_view_size=40%26customer-country=GB%26gender=female%26date_time=20241127T214141%26site_id=79%26site_area=department%26device=desktop%26fh_refview=lister%26fh_reffacet=brand#inline-facets"


def scrape_category(driver, url, category_label, price_category):
    driver.get(url)
    time.sleep(3)

    products = []

    while True:
        soup = BeautifulSoup(driver.page_source, "html.parser")

        product_elements = soup.find_all("div", class_ = "Product")

        for product in product_elements:
            brand = product.find("div", class_ = "brand" ).text if product.find("div", class_ = "brand") else "N/A"

            name = product.find("div", class_ = "productName" ).text if product.find("div", class_ = "productName") else "N/A"

            product_url = "https://www.sephora.co.uk" + product.find("a")["href"]

            price_integer = product.find("span", class_="Price-integer").text if product.find("span", class_="Price-integer") else "0"
            price_decimal = product.find("span", class_="Price-decimal").text if product.find("span", class_="Price-decimal") else "00"

            price = f"{price_integer}{price_decimal}"

            rating = product.find("span", class_ = "Rating-average").text if product.find("span", class_ = "Rating-average") else "N/A"

            image_url = product.find("img")["src"] if product.find("img") else "N/A"

            products.append({
                "Brand": brand,
                "Name": name,
                "Price": price,
                "Rating": rating,
                "Product URL": product_url,
                "Image URL": image_url,
                "Category": category_label,
                "Price Category": price_category
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

all_products.extend(scrape_category(driver, base_url_cleansers_budget, "Cleansers", "Budget-Friendly"))

all_products.extend(scrape_category(driver, base_url_cleansers_mid, "Cleansers", "Mid-range"))

all_products.extend(scrape_category(driver, base_url_cleansers_high, "Cleansers", "High-end"))

all_products.extend(scrape_category(driver, base_url_toners_budget, "Toners", "Budget-Friendly"))

all_products.extend(scrape_category(driver, base_url_toners_mid, "Toners", "Mid-range"))

all_products.extend(scrape_category(driver, base_url_toners_high, "Toners", "High-end"))

all_products.extend(scrape_category(driver, base_url_serums_budget, "Serums", "Budget-Friendly"))

all_products.extend(scrape_category(driver, base_url_serums_mid, "Serums", "Mid-range"))

all_products.extend(scrape_category(driver, base_url_serums_high, "Serums", "High-end"))

all_products.extend(scrape_category(driver, base_url_eyecreams_budget, "Eye-Creams", "Budget-Friendly"))

all_products.extend(scrape_category(driver, base_url_eyecreams_mid, "Eye-Creams", "Mid-range"))

all_products.extend(scrape_category(driver, base_url_eyecreams_high, "Eye-Creams", "High-end"))

all_products.extend(scrape_category(driver, base_url_moisturizers_budget, "Moisturizers", "Budget-Friendly"))

all_products.extend(scrape_category(driver, base_url_moisturizers_mid, "Moisturizers", "Mid-range"))

all_products.extend(scrape_category(driver, base_url_moisturizers_high, "Moisturizers", "High-end"))

all_products.extend(scrape_category(driver, base_url_sunscreens_budget, "Sunscreens", "Budget-Friendly"))

all_products.extend(scrape_category(driver, base_url_sunscreens_mid, "Sunscreens", "Mid-range"))

all_products.extend(scrape_category(driver, base_url_sunscreens_high, "Sunscreens", "High-end"))

df = pd.DataFrame(all_products)
df.to_csv("sephora_products_labeled.csv", index = False)
print("All products saved to sephora_products_labeled.csv")

driver.quit()