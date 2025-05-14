import pandas as pd

def fix_image_url(url):
    """Add https:// prefix to URLs missing a protocol"""
    if pd.notna(url) and not url.startswith(('http://', 'https://')):
        return f'https://{url}'
    return url


try:
    existing_df = pd.read_csv("sephora_products_labeled.csv")
    
    existing_df['Image URL'] = existing_df['Image URL'].apply(fix_image_url)
except FileNotFoundError:
    existing_df = pd.DataFrame()


new_df = pd.read_csv("sephora_products_labeled_men.csv")
new_df['Image URL'] = new_df['Image URL'].apply(fix_image_url)


combined_df = pd.concat([existing_df, new_df], ignore_index=True)


combined_df.to_csv("sephora_products_labeled_new.csv", index=False)
print("Dataset updated with fixed image URLs")