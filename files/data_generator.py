import random
from faker import Faker
import mysql.connector
from multiprocessing import Pool, Value

# Connect to MySQL
conn = mysql.connector.connect(
    host="localhost",
    port=3306,
    user="root",
    password="my-secret-pw",
    database="football_system",
    connect_timeout=60
)
cursor = conn.cursor()

# Instantiate Faker with a specific seed for reproducibility
fake = Faker()
Faker.seed()

# Shared progress counter using Value
progress = Value('i', 0)

# Function to generate random teams data
def generate_teams_data(_):
    team_name = fake.company()
    city = fake.city()
    stadium = f"{city} Stadium"
    manager = fake.name()
    league_id = random.randint(1, 3)

    with progress.get_lock():
        progress.value += 1

    if progress.value % 100000 == 0:
        print(f"{progress.value/1000}k")

    return team_name, city, stadium, manager, league_id

# Function to insert teams data into the database
# Function to insert teams data into the database
def insert_teams_data(team_data):
    batch_size = 1000  # Adjust the batch size as needed
    for i in range(0, len(team_data), batch_size):
        batch = team_data[i:i+batch_size]
        query = "INSERT INTO teams (name, city, stadium, manager, league_id) VALUES (%s, %s, %s, %s, %s)"
        cursor.executemany(query, batch)
        conn.commit()

# Number of teams you want to generate
num_teams_to_generate = 10000000

# Use multiprocessing Pool for parallel generation
if __name__ == "__main__":
    try:
        # Run the code with multiprocessing
        with Pool() as pool:
            teams_data_to_insert = pool.map(generate_teams_data, range(num_teams_to_generate))
            insert_teams_data(teams_data_to_insert)
    except KeyboardInterrupt:
        print("Process interrupted. Cleaning up...")
    finally:
        # Close the database connection
        cursor.close()
        conn.close()
