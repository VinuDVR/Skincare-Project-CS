import pandas as pd

try:
    existing_df = pd.read_csv("sephora_products_labeled.csv")
except FileNotFoundError:
    existing_df = pd.DataFrame()

# For all rows in existing_df, set the Gender column to "Womens".
if "Gender" not in existing_df.columns:
    existing_df["Gender"] = "Womens"
else:
    # Force all existing products to be labeled as "Womens" (unless already marked "Men")
    existing_df.loc[existing_df["Gender"] != "Men", "Gender"] = "Womens"

# Convert new men's products to DataFrame.
new_men_df = pd.read_csv("sephora_products_labeled_men.csv")

# Combine the existing data and new men's products.
combined_df = pd.concat([existing_df, new_men_df], ignore_index=True)

# Save the combined DataFrame back to the CSV file.
combined_df.to_csv("sephora_products_labeled.csv", index=False)
print("Combined products saved to sephora_products_labeled.csv")