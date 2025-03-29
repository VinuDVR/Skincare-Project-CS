import os
import math
import random
import requests
from pymongo import MongoClient
from time import sleep

# Set your MongoDB URI (replace with your actual URI or set as an environment variable)
MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://vinubasnayake:SbtbeJqgAxKsJlpT@cluster0.29w6v.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15",
    # Add more user agents as needed
]

def connect_to_db():
    client = MongoClient(MONGO_URI)
    db = client["skincare"]
    print("Connected to MongoDB database 'skincare'.")
    return db

def is_invalid_url(url):
    if not url:
        return True
    if isinstance(url, float) and math.isnan(url):
        return True
    if isinstance(url, str) and url.strip().lower() in ['nan', '']:
        return True
    return False

def get_random_headers():
    return {
        'User-Agent': random.choice(USER_AGENTS),
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    }

def check_url(session, url, product_id, retries=3):
    for attempt in range(retries):
        try:
            response = session.head(url, headers=get_random_headers(), timeout=10)
            # If we get a good response code, return it
            if response.status_code < 400:
                return True, response.status_code
            else:
                print(f"Product {product_id}: Attempt {attempt+1} got status code {response.status_code}.")
        except requests.RequestException as e:
            print(f"Product {product_id}: Attempt {attempt+1} error: {e}")
        sleep(2 * (attempt + 1))  # exponential backoff
    return False, None

def check_urls():
    db = connect_to_db()
    collection = db["products"]
    print("Retrieving products from collection 'products'...")
    products = list(collection.find({}, {"Product_ID": 1, "URL": 1}))
    total_products = len(products)
    print(f"Total products found: {total_products}")
    
    broken_count = 0
    valid_count = 0

    session = requests.Session()

    for product in products:
        product_id = product.get("Product_ID", "Unknown")
        url = product.get("URL")
        
        if is_invalid_url(url):
            print(f"Product {product_id}: Invalid URL value detected: {url}")
            broken_count += 1
            continue
        
        is_valid, status = check_url(session, url, product_id)
        if is_valid:
            print(f"Product {product_id}: Valid URL - {url} (Status code: {status})")
            valid_count += 1
        else:
            print(f"Product {product_id}: Broken link or unreachable URL - {url}")
            broken_count += 1

        # Random delay between requests to mimic human behavior
        sleep(random.uniform(1, 3))

    print(f"\nURL check completed: {total_products} products processed. {valid_count} valid URLs, {broken_count} broken or invalid URLs.")

if __name__ == "__main__":
    check_urls()
