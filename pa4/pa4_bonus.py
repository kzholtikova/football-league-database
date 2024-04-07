import mysql.connector


def rollback():
    db.rollback()
    print("Transaction rolled back due to the inconsistent data.")

    db.close()
    exit()


db = mysql.connector.connect(
    host="localhost",
    port=3306,
    user="root",
    password="my-secret-pw",
    auth_plugin='mysql_native_password',
    database="football_system"
)
c = db.cursor()

# update standing goals_for
db.start_transaction()

match_day_id = input("Enter match day id: ")  # 1
team_id = input("Enter team id: ")  # 6
match_id = input("Enter match id: ")  # 7 (team 10) - valid, 19 (team 30) - invalid
# team 6 - 2:2   team 10 - 4:2   team 30 - 3:2

standings_update = ("UPDATE standings s SET goals_for = goals_for + 1 "
                    f"WHERE match_day_id = {match_day_id} and team_id = {team_id};")
c.execute(standings_update)
if c.rowcount != 1:
    rollback()

standings_opponent_update = (f"UPDATE standings s JOIN football_system.attendees a on s.team_id = a.team_id "
                             f"SET goals_for = goals_against + 1 WHERE match_day_id = {match_day_id} "
                             f"and match_id = {match_id} and a.team_id != {team_id};")
c.execute(standings_opponent_update)
if c.rowcount != 1:
    rollback()

db.commit() # team 6 - 3:2   team 10 - 4:3   team 30 - 3:2
