import pandas as pd
from user_input import user_data

user_price_range = user_data["Price Range"]
user_routine_preference = user_data["Routine Preference"]
user_skin_type = user_data["Skin Type"]
user_skin_concerns = user_data["Skin Concerns"]

df = pd.read_csv("preprocessed_skincare_products.csv")

ingredient_skin = {
    'Acne or breakouts': ["salicylic acid", "benzoyl peroxide", "azelaic acid"],
    'Dry': ["hyaluronic acid", "ceramides", "glycerin"],
    'Oily': ["niacinamide", "zinc", "clay"],
    'Fine lines or wrinkles': ["retinol", "peptides", "antioxidants"],
    'Sensitive': ["aloe vera", "chamomile", "oatmeal"],
    'Redness or irritation': ["niacinamide", "hyaluronic acid", "salicylic acid"],
    'Uneven skin tone': ["vitamin c", "kojic acid", "azelaic acid"],
    'Dark spots': ["vitamin c", "kojic acid", "azelaic acid"],
    'Large pores': ["salicylic acid", "niacinamide", "clay"],
    'Dullness': ["vitamin c", "hyaluronic acid", "alpha hydroxy acids (ahas)"],
    'Dehydration': ["hyaluronic acid", "ceramides", "glycerin"],
    'Normal': [],
    'Combination': [],
    'None of the above': []
}

routine_mapping = {
    "Minimal (3 steps)": ["Cleansers", "Moisturizers", "Sunscreens"],
    "Moderate (4 steps)": ["Cleansers", "Serums", "Moisturizers", "Sunscreens"],
    "Extensive (6 steps)": ["Cleansers", "Toners", "Serums", "Eye Creams", "Moisturizers", "Sunscreens"]
}


def rule_based_filtering(data, price_range, routine_preference):
    
    filtered_data = data[data['Price Category'] == price_range]
    

    filtered_data = filtered_data[filtered_data['Rating'] >= 4.0]
    
    routine_categories = routine_mapping[routine_preference]
    filtered_data = filtered_data[filtered_data['Category'].isin(routine_categories)]

    return filtered_data



def score_products(df, user_skin_concerns, user_skin_type):
    required_ingredients = set(
        ingredient for concern in user_skin_concerns for ingredient in ingredient_skin[concern]
    )

    required_ingredients.update(ingredient_skin[user_skin_type])

    df["Score"] = 0

    print("Relevant Ingredients: ", required_ingredients)

    for idx, product in df.iterrows():
        product_ingredients = set(product["Ingredients"].lower().split(", "))
        match_score = sum(1 for ingredient in required_ingredients if ingredient in product_ingredients)
        df.at[idx, "Score"] = match_score

    
    recommended_products = df[df["Score"] > 0]
    return recommended_products.sort_values(by=["Score", "Rating"], ascending=[False, False])

filtered_products = rule_based_filtering(df, user_price_range, user_routine_preference)
recommended_products = score_products(filtered_products, user_skin_concerns, user_skin_type)


sunscreen_recommendations = df[(df["Category"] == "Sunscreens") &
                               (df["Price Category"] == user_price_range)].head(1)

eye_cream_recommendations = pd.DataFrame()
if user_routine_preference == "Extensive (6 steps)":
    eye_cream_recommendations = df[(df["Category"] == "Eye Creams") &
                                   (df["Price Category"] == user_price_range)].head(1)
    



final_recommended_products = pd.concat([recommended_products, sunscreen_recommendations, eye_cream_recommendations]).drop_duplicates()
print("Recommended Products: \n", recommended_products)

final_recommended_products.to_csv('recommended_skincare_products.csv', index=False)
print("Recommendations saved to recommended_skincare_products.csv")


filtering_category = (
    final_recommended_products.groupby("Category", as_index = False)
    .first()
    .sort_values(by = "Category")
)

print("First Instance Products for Routine Preference: \n", filtering_category)

filtering_category.to_csv('final_recommendation.csv', index = False)
print("Finaal recommendation saved to final_recommendation.csv")