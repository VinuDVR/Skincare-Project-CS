from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer

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

app = Flask(__name__)
CORS(app)

df = pd.read_csv('preprocessed_skincare_products.csv')

@app.route('/recommend', methods=['POST'])


def recommend():
    user_data = request.json

    user_price_range = user_data["Price Range"]
    user_routine_preference = user_data["Routine Preference"]
    user_skin_type = user_data["Skin Type"]
    user_skin_concerns = user_data["Skin Concerns"]
    user_gender = user_data["Gender"]

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
    
    filtered_products = rule_based_filtering(df, user_price_range, user_routine_preference, user_gender)

    def recommendation_tfidf(filtered_data, user_skin_concerns, user_skin_type):

        relevant_ingredients = [
            ingredient for concern in  user_skin_concerns for ingredient in ingredient_skin[concern]
        ]

        relevant_ingredients.extend(ingredient_skin[user_skin_type])
        relevant_ingredients_str = " ".join(relevant_ingredients)
        print("Relevant Ingredients: ", relevant_ingredients)

        tfidf_vectorizer = TfidfVectorizer()
        tfidf_matrix = tfidf_vectorizer.fit_transform(filtered_products["Ingredients"].fillna(""))

        user_vector = tfidf_vectorizer.transform([relevant_ingredients_str])

        filtered_data["Similarity"] = cosine_similarity(user_vector, tfidf_matrix).flatten()


        return filtered_data.sort_values(by=["Similarity", "Rating"], ascending=[False, False])
    
    recommended_products = recommendation_tfidf(filtered_products, user_skin_concerns, user_skin_type)

    if user_gender == "Man":
        sunscreen_recommendations = df[df["Category"] == "Sunscreens"].head(1)
    else:
        sunscreen_recommendations = df[(df["Category"] == "Sunscreens") &
                                   (df["Price Category"] == user_price_range)].head(1)


    eye_cream_recommendations = pd.DataFrame()
    if user_routine_preference == "Extensive (6 steps)":
        eye_cream_recommendations = df[(df["Category"] == "Eye-Creams") & 
                                        (df["Price Category"] == user_price_range)].head(1)
    

    final_recommendations = pd.concat([recommended_products, sunscreen_recommendations, eye_cream_recommendations]).drop_duplicates()

    first_instance = (
        final_recommendations.groupby("Category", as_index=False)
        .first()
        .sort_values(by="Category")
    )

    print("First instance data:")
    print(first_instance[['Brand', 'Name', 'Category', 'Price', 'Rating', 
                     'Image URL', 'Product URL']].to_dict(orient='records'))

    response_data = {
        "routine" : first_instance[['Brand', 'Name', 'Category', 'Price', 'Rating', 'Image URL', 'Product URL']].to_dict(orient='records')

    }

    return jsonify(response_data)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

    

