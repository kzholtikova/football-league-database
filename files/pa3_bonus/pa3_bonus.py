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
