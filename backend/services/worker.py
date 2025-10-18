import schedule
import time
import os
from app import update_product_prices  # Import the function from your app.py
from dotenv import load_dotenv

load_dotenv()

print("Starting background worker...")

# Run the update job once immediately on startup
try:
    print("Running initial price update...")
    update_product_prices()
    print("Initial price update complete.")
except Exception as e:
    print(f"Initial price update failed: {e}")

# Then, schedule it to run every 6 hours
schedule.every(6).hours.do(update_product_prices)
print("Scheduled price update every 6 hours.")

while True:
    schedule.run_pending()
    time.sleep(60) # Check for pending jobs every 60 seconds