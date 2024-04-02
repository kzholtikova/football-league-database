from faker import Faker
import mysql.connector

db = mysql.connector.connect(
    host="localhost",
    port=3306,
    user="root",
    password="my-secret-pw",
    auth_plugin='mysql_native_password',
    database="football_system"
)
c = db.cursor()

referees_create = """CREATE TABLE referees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    nationality TEXT NOT NULL,
    experience INT)"""
c.execute(referees_create)
c.execute("DESC referees")
print("DESC referees")
for i in c:
    print(i)

fake = Faker()
referees_insert = """INSERT INTO referees (name, nationality, experience) VALUES (%s, %s, %s)"""
referees_data = [(fake.name(), fake.country(), fake.random.randint(0, 5)) for _ in range(5)]
c.executemany(referees_insert, referees_data)
db.commit()
print("\nData to INSERT INTO referees")
for r in referees_data:
    print(r)

referee_id_col_add = """ALTER TABLE matches ADD COLUMN referee_id INT"""
matches_alter = """ALTER TABLE matches ADD FOREIGN KEY (referee_id) REFERENCES referees(id)"""
c.execute(referee_id_col_add)
c.execute(matches_alter)
db.commit()
c.execute("DESC matches")
print("\nDESC matches")
for i in c:
    print(i)

matches_update = """UPDATE matches SET referee_id = %s WHERE id = %s"""
matches_referee_id_data = [(fake.random.randint(1, 5), i) for i in range(1, 26)]
c.executemany(matches_update, matches_referee_id_data)
db.commit()
c.execute("SELECT name, referee_id FROM matches")
print("\nUPDATE matches")
for m in c:
    print(m)

# matches with experienced referees
matches_select = """SELECT m.name, r.name, r.experience FROM matches m
    JOIN referees r on r.id = m.referee_id
    WHERE r.experience >= 3"""
c.execute(matches_select)
matches_data = c.fetchall()
print("\nSELECT FROM matches")
for m in matches_data:
    print(m)

refereed_delete_update = """UPDATE matches SET referee_id = NULL 
    WHERE referee_id IN (SELECT id FROM referees WHERE experience = 0)"""
referees_delete = """DELETE FROM referees WHERE experience = 0"""
c.execute(refereed_delete_update)
c.execute(referees_delete)
db.commit()
c.execute("SELECT * FROM referees")
print("\nDELETE FROM referees")
for r in c:
    print(r)

db.close()
