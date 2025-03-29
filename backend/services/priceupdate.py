from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
import schedule
import time
import threading
from bs4 import BeautifulSoup
import requests
from datetime import datetime
from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()
MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://vinubasnayake:SbtbeJqgAxKsJlpT@cluster0.29w6v.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")

def get_database():
    client = MongoClient(MONGO_URI)
    return client['skincare']

db = get_database()
products_collection = db['products']

for product in products_collection.find():
    try:
        price = float(product["Price"])
        products_collection.update_one(
            {'_id': product['_id']},
            {'$set': {'Price': price}}
        )
    except (ValueError, TypeError):
        print(f"Skipping invalid price for product {product.get('Product_ID')}")