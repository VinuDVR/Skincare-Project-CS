import os
import random
import time
import threading
import concurrent.futures
import schedule
from datetime import datetime
import re
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from bs4 import BeautifulSoup
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from dotenv import load_dotenv
from openai import OpenAI

#openai.api_key = "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"

load_dotenv()
MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://vinubasnayake:SbtbeJqgAxKsJlpT@cluster0.29w6v.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")

app = Flask(__name__)
CORS(app)
#CORS(app, resources={r"/*": {"origins": "https://your-flutter-app-domain.com"}})

def get_database():
    client = MongoClient(MONGO_URI)
    return client['skincare']

# CSV initialization
# df = pd.read_csv('preprocessed_skincare_products.csv')

routine_mapping = {
    "Minimal (3 steps)": ["Cleansers", "Moisturizers", "Sunscreens"],
    "Moderate (4 steps)": ["Cleansers", "Serums", "Moisturizers", "Sunscreens"],
    "Extensive (6 steps)": ["Cleansers", "Toners", "Serums", "Eye-Creams", "Moisturizers", "Sunscreens"]
}

ingredient_skin = {
    'Acne or breakouts': ["salicylic acid", "benzoyl peroxide", "azelaic acid", "vitamin c", "vitamin b3"],
    'Fine lines or wrinkles': ["retinol", "peptides", "antioxidants", "hyaluronic acid", "sodium hyaluronate", "hyaluronan", "glycoaminoglycan", "vitamin a", "palmitoyl pentapeptide", "acetyl tetrapeptide-9", "acetyl hexapeptide 3", "acetyl hexapeptide 8", "acetyl hexapeptide 20", "palmitoyl oligopeptide", "tripeptide 1"],
    'Redness or irritation': ["niacinamide", "hyaluronic acid", "salicylic acid", "sodium hyaluronate", "hyaluronan", "glycoaminoglycan"],
    'Uneven skin tone': ["vitamin c", "kojic acid", "azelaic acid", "hyaluronic acid", "sodium hyaluronate", "hyaluronan", "glycoaminoglycan", "glycolic acid", "lactic acid"],
    'Dark spots': ["vitamin c", "kojic acid", "azelaic acid"],
    'Large pores': ["salicylic acid", "niacinamide", "clay", "glycolic acid", "lactic acid", "vitamin b3"],
    'Dullness': ["vitamin c", "hyaluronic acid", "alpha hydroxy acids (ahas)", "sodium hyaluronate", "hyaluronan", "glycoaminoglycan"],
    'Dehydration': ["hyaluronic acid", "ceramides", "glycerin", "sodium hyaluronate", "hyaluronan", "glycoaminoglycan"],
    
    'Normal': [],
    'Dry': ["hyaluronic acid", "ceramides", "glycerin", "vitamin c", "sodium hyaluronate", "hyaluronan", "glycoaminoglycan"],
    'Oily': ["niacinamide", "zinc", "clay", "vitamin c", "salicylic acid"],
    'Sensitive': ["aloe vera", "chamomile", "oatmeal"],
    'Combination': ["vitamin c", "salicylic acid"],
    'None of the above': []
}

def initialize_database():
    df = pd.read_csv('preprocessed_skincare_products.csv')

    if 'Product URL' in df.columns and 'URL' not in df.columns:
        df.rename(columns={'Product URL': 'URL'}, inplace=True)

    df['last_updated'] = datetime.now().isoformat()

    if 'Product_ID' not in df.columns:
        df['Product_ID'] = df['Brand'] + '_' + df['Name'].str.replace(' ', '_')

    products = df.to_dict('records')

    db = get_database()
    products_collection = db['products']

    if products_collection.count_documents({}) > 0:
        for product in products:
            products_collection.update_one(
                {'Product_ID': product['Product_ID']},
                {'$set': product},
                upsert=True
            )
    else:
        products_collection.insert_many(products)

    print("Database initialized with CSV data")

def get_random_headers():
    user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
    ]
    return {
        "User-Agent": random.choice(user_agents),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    }

def update_price_for_product(product, products_collection):
    product_id = product.get('Product_ID')
    url = product.get('URL')
    brand = product.get('Brand')
    name = product.get('Name')

    # Validate URL before processing
    if not url or str(url).strip().lower() == 'nan':
        print(f"Invalid URL for product {product_id} - skipping")
        return None

    try:
        headers = get_random_headers()
        response = requests.get(url, headers=headers, timeout=15)
        if response.status_code != 200:
            print(f"Failed to retrieve {url}, status code: {response.status_code}")
            return None

        soup = BeautifulSoup(response.content, 'html.parser')
        product_section = soup.select_one('div.item')

        if product_section:
            price_text = (
                product_section.find("span", class_="Price").text.strip()
                if product_section.find("span", class_="Price")
                else "0"
            )

            price_cleaned = re.sub(r'[^\d.]', '', price_text)

            try:
                price = float(price_cleaned)
            except ValueError:
                price = None

            products_collection.update_one(
                {'Product_ID': product_id},
                {
                    '$set': {
                        'Price': price,
                        'last_updated': datetime.now().isoformat()
                    }
                }
            )
            print(f"Updated price for product {product_id}, {url}: {price}")
            # Random delay to mimic human behavior
            time.sleep(random.uniform(1, 7))
            return product_id
        else:
            print(f"Product section not found for {product_id} at {url}")
            return None

    except Exception as e:
        print(f"Error updating price for product {product_id}: {e}")
        return None

def update_product_prices():
    print("Starting price update job at", datetime.now().isoformat())
    db = get_database()
    products_collection = db['products']

    products = list(products_collection.find({}, {'Product_ID': 1, 'URL': 1, 'Brand': 1, 'Name': 1}))
    print(f"Total products to update: {len(products)}")

    update_count = 0

    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        future_to_product = {
            executor.submit(update_price_for_product, product, products_collection): product
            for product in products
        }
        for future in concurrent.futures.as_completed(future_to_product):
            result = future.result()
            if result:
                update_count += 1

    print(f"Price update job completed. Updated {update_count} products.")

def start_scheduler():
    update_product_prices()
    schedule.every(6).hours.do(update_product_prices)
    while True:
        schedule.run_pending()
        time.sleep(60)

def get_products_from_db():
    db = get_database()
    products_collection = db['products']
    products = list(products_collection.find({}))
    df = pd.DataFrame(products)
    if '_id' in df.columns:
        df = df.drop('_id', axis=1)
    return df

def rule_based_filtering(data, price_range, routine_preference, gender):
    if gender == "Man":
        filtered_data = data[
            ((data["Gender"] == "Mens") | (data["Price Category"] == "No Range")) &
            (data["Category"].isin(routine_mapping[routine_preference]))
        ]
    else:
        filtered_data = data[
            (data["Price Category"] == price_range) & 
            (data["Category"].isin(routine_mapping[routine_preference])) & 
            (data["Gender"] == "Womens")
        ]
    filtered_data = filtered_data[filtered_data['Rating'] >= 4.0]
    return filtered_data

def recommendation_tfidf(filtered_data, user_skin_concerns, user_skin_type):
    relevant_ingredients = [
        ingredient for concern in user_skin_concerns for ingredient in ingredient_skin.get(concern, [])
    ]
    relevant_ingredients.extend(ingredient_skin.get(user_skin_type, []))
    relevant_ingredients_str = " ".join(relevant_ingredients)
    
    tfidf_vectorizer = TfidfVectorizer()
    tfidf_matrix = tfidf_vectorizer.fit_transform(filtered_data["Ingredients"].fillna(""))
    user_vector = tfidf_vectorizer.transform([relevant_ingredients_str])
    
    filtered_data = filtered_data.copy()  
    filtered_data["Similarity"] = cosine_similarity(user_vector, tfidf_matrix).flatten()
    recommended = filtered_data.sort_values(by=["Similarity", "Rating"], ascending=[False, False])
    return recommended

def initialize_scheduler():
    scheduler_thread = threading.Thread(target=start_scheduler)
    scheduler_thread.daemon = True
    scheduler_thread.start()

@app.route('/recommend', methods=['POST'])
def recommend():
    df = get_products_from_db()
    data = request.get_json()
    user_price_range = data.get("Price Range")
    user_routine_preference = data.get("Routine Preference")
    user_skin_type = data.get("Skin Type")
    user_skin_concerns = data.get("Skin Concerns")  
    user_gender = data.get("Gender")
    
    filtered_products = rule_based_filtering(df, user_price_range, user_routine_preference, user_gender)
    recommended_products = recommendation_tfidf(filtered_products, user_skin_concerns, user_skin_type)
    
    if user_gender == "Man":
        sunscreen_recommendations = df[df["Category"] == "Sunscreens"].head(1)
    else:
        sunscreen_recommendations = df[(df["Category"] == "Sunscreens") & (df["Price Category"] == user_price_range)].head(1)
    
    eye_cream_recommendations = pd.DataFrame()
    if user_routine_preference == "Extensive (6 steps)":
        eye_cream_recommendations = df[(df["Category"] == "Eye-Creams") & (df["Price Category"] == user_price_range)].head(1)
    
    final_recommendations = pd.concat([recommended_products, sunscreen_recommendations, eye_cream_recommendations]).drop_duplicates()
    final_recommendations_sorted = final_recommendations.sort_values(
        ['Category', 'Similarity', 'Rating'], 
        ascending=[True, False, False]
    )
    final_recommendations_sorted['Rank'] = final_recommendations_sorted.groupby('Category').cumcount() + 1
    categories_in_routine = routine_mapping[user_routine_preference]
    top_2_recommendations = final_recommendations_sorted[
        final_recommendations_sorted['Category'].isin(categories_in_routine)
    ].groupby('Category').head(2)
    
    primary_recommendations = top_2_recommendations[top_2_recommendations['Rank'] == 1]
    alternate_recommendations = top_2_recommendations[top_2_recommendations['Rank'] == 2]
    print("Primary: ", primary_recommendations)
    print("Alternate: ", alternate_recommendations)
    
    primary_json = primary_recommendations.replace({np.nan: None}).to_dict(orient='records')
    alternate_json = alternate_recommendations.replace({np.nan: None}).to_dict(orient='records')
    

    response = {
        "primary": primary_json,
        "alternate": alternate_json
    }
    return jsonify(response)

@app.route('/ask', methods=['POST'])
def ask():
    client = OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key="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",
    )
    
    user_msg = request.json['message']

    response = client.chat.completions.create(
        model="meta-llama/llama-4-scout:free",
        messages= [
            {"role": "system", "content": "You are a helpful skincare assistant. Provide medium sized, concise answers to the prompts. If they ask for product recommendations, ask them to use the SkinGenie in a polite and a bit funny way and if they keep asking for recommendation give them some general recommendation while telling them to use SkinGenie."},
            {"role": "user", "content": user_msg}
        ]
    )


    reply = response.choices[0].message.content
    print(reply)
    return jsonify({'reply': reply})

if __name__ == '__main__':
    #initialize_database()
    #initialize_scheduler()
    app.run(host='0.0.0.0', port=5000)
