import os
from pymongo import MongoClient
import math


MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://vinubasnayake:SbtbeJqgAxKsJlpT@cluster0.29w6v.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")

def connect_to_db():
    client = MongoClient(MONGO_URI)
    db = client["skincare"]
    print("Connected to MongoDB database 'skincare'.")
    return db

def delete_duplicates(db):
    collection = db["products"]
    print("Working on collection 'products'.")

    
    pipeline = [
        {
            "$group": {
                "_id": "$Product_ID",
                "count": {"$sum": 1},
                "docs": {"$push": "$_id"}
            }
        },
        {
            "$match": {"count": {"$gt": 1}}
        }
    ]

    print("Running aggregation pipeline to identify duplicate records...")
    duplicate_groups = list(collection.aggregate(pipeline))
    print(f"Found {len(duplicate_groups)} duplicate groups.")

    
    total_deleted = 0
    for group in duplicate_groups:
        product_id = group["_id"]
        count = group["count"]
        print(f"\nDuplicate group for Product_ID '{product_id}' has {count} records.")
        doc_ids = group["docs"]

        
        id_to_keep = doc_ids[0]
        print(f"Keeping document with _id: {id_to_keep}")
        duplicate_ids = doc_ids[1:]

        for dup_id in duplicate_ids:
            result = collection.delete_one({"_id": dup_id})
            if result.deleted_count == 1:
                total_deleted += 1
                print(f"Deleted duplicate document with _id: {dup_id}")
            else:
                print(f"Failed to delete document with _id: {dup_id}")

    print(f"\nDuplicate deletion process completed. Total duplicates deleted: {total_deleted}")

if __name__ == "__main__":
    db = connect_to_db()
    delete_duplicates(db)
