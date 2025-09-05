import psycopg2
import time
from datetime import datetime

# Database connection settings
conn = psycopg2.connect(
    host="172.20.204.64",
    dbname="postgres",
    user="postgres",
    password="P@ssw0rd2025"
)
cursor = conn.cursor()

def insert_data():
    name = "TestName"
    address = "TestAddress"
    cursor.execute(
        "INSERT INTO test.hello (name, address) VALUES (%s, %s) RETURNING id",
        (name, address)
    )
    inserted_id = cursor.fetchone()[0]
    conn.commit()
    print(f"[{datetime.now()}] Inserted ID: {inserted_id}")
    return inserted_id

def read_data(record_id):
    cursor.execute("SELECT * FROM test.hello WHERE id = %s", (record_id,))
    row = cursor.fetchone()
    print(f"[{datetime.now()}] Read Record: {row}")

try:
    while True:
        inserted_id = insert_data()
        time.sleep(1)
        read_data(inserted_id)
        time.sleep(1)
except KeyboardInterrupt:
    print("Stopped by user.")
finally:
    cursor.close()
    conn.close()
