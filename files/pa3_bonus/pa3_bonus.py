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

db.close()
