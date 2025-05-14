import os
import random
import time
import threading
import concurrent.futures
import schedule
from datetime import datetime, timedelta
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
from bson.objectid import ObjectId
import uuid
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash


load_dotenv()

#Connecting to the MongoDB and initiating the collections
MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://vinubasnayake:SbtbeJqgAxKsJlpT@cluster0.29w6v.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
client = MongoClient(MONGO_URI)
db = client['skincare']
users_collection = db['users']
history_collection = db['history']

#Starting the Flask app
app = Flask(__name__)
CORS(app, supports_credentials=True)

#JWT tokens for account authentications
app.config['JWT_SECRET_KEY'] = os.getenv("SECRET_KEY", "45C1BAD77EE36")
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)
jwt = JWTManager(app)


def get_database():
    return client['skincare']

#Mapping the products for each routine types
routine_mapping = {
    "Minimal (3 steps)": ["Cleansers", "Moisturizers", "Sunscreens"],
    "Moderate (4 steps)": ["Cleansers", "Serums", "Moisturizers", "Sunscreens"],
    "Extensive (6 steps)": ["Cleansers", "Toners", "Serums", "Eye-Creams", "Moisturizers", "Sunscreens"]
}

#Ingredients for each skin concerns and skin types
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
    #Load products from the CSV file
    df = pd.read_csv('preprocessed_skincare_products.csv')
    
    #Change the column name 
    if 'Product URL' in df.columns and 'URL' not in df.columns:
        df.rename(columns={'Product URL': 'URL'}, inplace=True)
    
    #Add the last updated data column
    df['last_updated'] = datetime.now().isoformat()
    
    #Add a unique Product-ID
    if 'Product_ID' not in df.columns:
        df['Product_ID'] = df['Brand'] + '_' + df['Name'].str.replace(' ', '_')
    
    #Insert the data into the MongoDB
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

#Gives random user-agents for web-scraping to avoid detection
def get_random_headers():
    user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
    ]
    return {"User-Agent": random.choice(user_agents)}

#Get and update the price for products
def update_price_for_product(product, products_collection):
    product_id = product.get('Product_ID')
    url = product.get('URL')
    brand = product.get('Brand')
    name = product.get('Name')
    
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
            
            time.sleep(random.uniform(1, 7))
            return product_id
        else:
            print(f"Product section not found for {product_id} at {url}")
            return None
    except Exception as e:
        print(f"Error updating price for product {product_id}: {e}")
        return None

#Update the proces for all products using
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

#Do the price update every 6 hours
def start_scheduler():
    update_product_prices()
    schedule.every(6).hours.do(update_product_prices)
    while True:
        schedule.run_pending()
        time.sleep(60)

#Run the scheduler
def initialize_scheduler():
    scheduler_thread = threading.Thread(target=start_scheduler)
    scheduler_thread.daemon = True
    scheduler_thread.start()

#Get all the products from the Mongo
def get_products_from_db():
    db = get_database()
    products_collection = db['products']
    products = list(products_collection.find({}))
    df = pd.DataFrame(products)
    
    if '_id' in df.columns:
        df = df.drop('_id', axis=1)
    return df

#Filter the products based on users price range, routine and gender
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

#Recommend products based on TF-IDF similarity on ingredients
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


@app.route('/register', methods=['POST'])
def register():
    db = get_database()
    users_collection = db['users']
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    
    
    if users_collection.find_one({"email": email}):
        return jsonify({"message": "User already exists"}), 400

    
    hashed_password = generate_password_hash(password)

    
    user_id = str(uuid.uuid4())
    user_data = {
        "_id": user_id,
        "email": email,
        "password_hash": hashed_password,
        "created_at": datetime.now().isoformat()
    }
    users_collection.insert_one(user_data)

    
    access_token = create_access_token(identity=user_id)
    return jsonify({"message": "User registered successfully", "access_token": access_token}), 201


@app.route('/login', methods=['POST'])
def login():
    db = get_database()
    users_collection = db['users']
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"message": "Email and password are required"}), 400

    user = users_collection.find_one({"email": email})
    if not user or not check_password_hash(user['password_hash'], password):
        return jsonify({"message": "Invalid credentials"}), 401

    #Creating JWT token
    access_token = create_access_token(identity=str(user["_id"]))
    
    return jsonify({
        "message": "Login successful",
        "access_token": access_token
    }), 200


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

    
    primary_json = primary_recommendations.replace({np.nan: None}).to_dict(orient='records')
    alternate_json = alternate_recommendations.replace({np.nan: None}).to_dict(orient='records')

    
    response = {
        "primary": primary_json,
        "alternate": alternate_json
    }

    #Saving the recommendations of the user is logged in
    auth_header = request.headers.get('Authorization')
    if auth_header and auth_header.startswith('Bearer '):
        try:
            
            current_user = get_jwt_identity()
            if current_user:
                history_entry = {
                    "user_id": current_user,
                    "filters": {
                        "Price Range": user_price_range,
                        "Routine Preference": user_routine_preference,
                        "Skin Type": user_skin_type,
                        "Skin Concerns": user_skin_concerns,
                        "Gender": user_gender
                    },
                    "recommendations": {
                        "primary": primary_json,
                        "alternate": alternate_json
                    },
                    "timestamp": datetime.utcnow().isoformat()
                }
                history_collection.insert_one(history_entry)
        except Exception as e:
            print(f"Error saving history: {e}")

    return jsonify(response)

#Endpoint to check if the user JWT token is valid
@app.route('/check-auth', methods=['GET'])
@jwt_required()
def check_auth():
    current_user = get_jwt_identity()
    return jsonify({"isLoggedIn": True, "user_id": current_user}), 200

#Saving users recommendation histroy in Mongo
@app.route('/history', methods=['POST'])
@jwt_required()

def save_history():
    current_user = get_jwt_identity()
    print(f"User ID from JWT: {current_user}")
    
    data = request.get_json()
    history_entry = {
        "user_id": current_user,
        "filters": data.get("filters"),
        "recommendations": data.get("recommendations"),
        "timestamp": datetime.utcnow().isoformat()
    }
    history_collection.insert_one(history_entry)

    return jsonify({"message": "History saved successfully"}), 201

#Get users recommendation history
@app.route('/history', methods=['GET'])
@jwt_required()

def get_history():
    current_user = get_jwt_identity()
    print(f"User ID from JWT: {current_user}")
    
    db = get_database()
    history_collection = db['history']
    print(f"History collection initialized: {history_collection}")
    
    history = list(history_collection.find({"user_id": current_user}, {"_id": 0}))
    
    return jsonify({"history": history}), 200

#Connect to OpenRouter API to use AI chat model
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
    initialize_scheduler()
    app.run(host='0.0.0.0', port=5000)