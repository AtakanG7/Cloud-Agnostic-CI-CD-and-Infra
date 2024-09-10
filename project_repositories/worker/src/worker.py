import time
import random
import os
from pymongo import MongoClient, errors
from pymongo.errors import ServerSelectionTimeoutError

DB_HOST = os.getenv('DB_HOST', 'localhost')  # Ensure this matches your environment variable name
DB_PORT = os.getenv('DB_PORT', '27017')      # Ensure this matches your environment variable name
DB_NAME = os.getenv('DB_NAME', 'mydatabase') # Ensure this matches your environment variable name

# Construct the database URL
DATABASE_URL = f"mongodb://{DB_HOST}:{DB_PORT}/{DB_NAME}"

def generate_dummy_data():
    """
    Generate dummy data ensuring it matches the expected model format.
    """
    return {
        "createdAt": time.time(),
        "username": f"user{random.randint(1, 1000)}",  # Ensure username is unique if necessary
        "email": f"user{random.randint(1, 1000)}@example.com"  # Ensure email is unique if necessary
    }

def write_data():
    """
    Connect to MongoDB and insert data into the database.
    """
    try:
        client = MongoClient(DATABASE_URL, serverSelectionTimeoutMS=5000)
        db = client[DB_NAME]
        collection = db.users

        data = generate_dummy_data()

        result = collection.insert_one(data)
        print(f"Inserted data with id {result.inserted_id}")

    except ServerSelectionTimeoutError:
        print("Error: Could not connect to MongoDB. Check your connection settings.")
    except errors.PyMongoError as e:
        print(f"MongoDB error: {e}")
    except ValueError as ve:
        print(f"Value error: {ve}")
    except Exception as e:
        print(f"Unexpected error: {e}")

def main():
    while True:
        write_data()
        time.sleep(10)

if __name__ == "__main__":
    main()
