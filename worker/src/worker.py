import time
import random
import os
from pymongo import MongoClient

DATABASE_URL = f"mongodb://{DB_HOST}:{DB_PORT}/{DB_NAME}"

def generate_dummy_data():
    return {
        "timestamp": time.time(),
        "value": random.random(),
        "message": f"Random data point {random.randint(1, 1000)}"
    }

def write_data():
    client = MongoClient(DATABASE_URL)
    db = client[DB_NAME]
    collection = db.data

    data = generate_dummy_data()
    result = collection.insert_one(data)
    print(f"Inserted data with id {result.inserted_id}")

def main():
    while True:
        write_data()
        time.sleep(10)

if __name__ == "__main__":
    main()
