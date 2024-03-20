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
Faker.seed(14)

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


def generate_attendees_data(_):
    match_id = random.randint(1, 25)
    team_id = random.randint(1, 21000034)
    is_home = random.randint(0, 1)
    is_winner = random.randint(0, 1)

    with progress.get_lock():
        progress.value += 1

    if progress.value % 100000 == 0:
        print(f"{progress.value/1000}k")

    return match_id, team_id, is_home, is_winner


def insert_data(data, query):
    batch_size = 1000  # Adjust the batch size as needed
    for i in range(0, len(data), batch_size):
        batch = data[i:i+batch_size]
        cursor.executemany(query, batch)
        conn.commit()


# Number of records you want to generate
num_records_to_generate = 1000000
insert_statement = "INSERT INTO attendees2 (match_id, team_id, is_home, is_winner) VALUES (%s, %s, %s, %s)"

# Use multiprocessing Pool for parallel generation
if __name__ == "__main__":
    try:
        # Run the code with multiprocessing
        with Pool() as pool:
            data_to_insert = pool.map(generate_attendees_data, range(num_records_to_generate))
            insert_data(data_to_insert, insert_statement)
    except KeyboardInterrupt:
        print("Process interrupted. Cleaning up...")
    finally:
        # Close the database connection
        cursor.close()
        conn.close()
