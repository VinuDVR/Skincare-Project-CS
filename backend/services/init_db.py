import os
from pathlib import Path
import pandas as pd
from datetime import datetime
from pymongo import MongoClient
from dotenv import load_dotenv

# --- Copy these functions from your app.py ---

load_dotenv(Path(__file__).with_name('.env'))

MONGO_URI = os.getenv("MONGO_URI")
if not MONGO_URI:
    raise RuntimeError("MONGO_URI must be configured in the environment")
client = MongoClient(MONGO_URI)
db = client['skincare']

def get_database():
    return client['skincare']

def initialize_database():
    # (Paste your entire initialize_database function here)
    csv_path = Path(__file__).resolve().parents[2] / 'preprocessed_skincare_products.csv'
    df = pd.read_csv(csv_path)
    
    if 'Product URL' in df.columns and 'URL' not in df.columns:
        df.rename(columns={'Product URL': 'URL'}, inplace=True)
    
    df['last_updated'] = datetime.now().isoformat()
    
    if 'Product_ID' not in df.columns:
        df['Product_ID'] = df['Brand'] + '_' + df['Name'].str.replace(' ', '_')
    
    products = df.to_dict('records')
    db = get_database()
    products_collection = db['products']

    if products_collection.count_documents({}) > 0:
        print("Database already contains data. Upserting records...")
        for product in products:
            products_collection.update_one(
                {'Product_ID': product['Product_ID']},
                {'$set': product},
                upsert=True
            )
    else:
        print("Database is empty. Inserting new records...")
        products_collection.insert_many(products)
    
    print("Database initialization/update complete.")

# --- End of copied functions ---

if __name__ == "__main__":
    print("Connecting to MongoDB and initializing database...")
    initialize_database()
