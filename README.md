## Description
A relational database for a football league system. A football league system is a hierarchy of leagues that compete in the same sport. Each league has several teams that play against each other in a round-robin format. Points rank the teams, goal difference, and goals scored. The top teams of each league may be promoted to a higher league, while the bottom teams may be relegated to a lower league. 

## Table of contents
1. [Tables creation](pa1)
2. [Basic queries](pa2)
   * [Indexes ](pa2/indexing.sql)
3. [34 queries](pa3) (correlated, non-correlated subqueries)
   * [Simple CRUD](pa3_bonus) operation via the application layer
4. [Stored procedures & Transactions](pa4)
   * [Transaction](pa4_bonus) via the application layer
5. [Views](pa5)
   * [GitLab repo](https://gitlab.com/idb573515/dbe-assignment-01-kzholtikova)
6. [Practice](practice)

## Structure
* `teams`: Stores information about each team in the league system, such as name, city, stadium, and manager.<br>
* `players`: Stores information about each player who belongs to one or more teams in the league system, such as name, birthdate, nationality, and number.<br>
* `team_squads`: Junction table that ties together teams and players. Establishes many-to-many relationship.<br>
* `seasons`: Describes seasons, has attributes such as name ('Summer 2023') and start date.<br>
* `leagues`: Describes leagues, has the following attributes: name, number of teams.<br>
* `match_days`: Stores information about every match day for every league during every season.<br>
* `matches`: Stores information about each match that is played between two teams in the league system, such as datetime, venue, and match day.<br>
* `attendees`: Ties together teams and matches. Establishes many-to-many relationships. Holds information about was a team playing at home and whether they won the match.<br>
* `goals`: Stores information about each goal that is scored in a match, such as time, player, and attendee.<br>
* `standings`: Stores information about every team's results in every league after every match day. Contains the following attributes: match day, team, points (won = 3, drawn = 1, lost = 0), played, won, drawn, lost, goals_for, goals_against. <be>

## Diagram
![football_system](https://github.com/x01-software-engineering/dbe-assignment-01-kzholtikova/blob/structuring/res/football_system.png)

## How to launch
1. **Clone GitHub Repository**. Clone the GitHub repository containing your SQL files to your local machine using Git or GitHub Desktop.
2. **Install Docker**. If you haven't already, download and install Docker Desktop from the official website (https://www.docker.com/products/docker-desktop).
3. **Launch MySQL Docker Container**:
   * Open a terminal or command prompt. Run the following command to pull the MySQL Docker image and start a container:
     ```
     $ docker run --name mysql-container -e MYSQL_ROOT_PASSWORD=my-secret-pw -p 3306:3306 -v "${env:USERPROFILE}\.mysql:/var/lib/mysql" --name my-sql mysql```
4. **Install Rider MySQL Plugin**. If you haven't already, install the MySQL plugin for JetBrains Rider. You can find it in Rider's Plugin Marketplace.
5. **Connect to MySQL Database**:
   * Open Rider and go to the Database tool window (View > Tool Windows > Database).
   * Click the + icon and select Data Source > MySQL.
   * Enter the following details: Host: localhost; Port: 3306; User: root; Password: password (or the password you specified)
   * Click Test Connection to ensure connectivity, then click OK.
6. **Run SQL Files**.
7. **Verify Execution**. After running the SQL files, you can verify that the database schema and data were created or updated as expected by querying the database from Rider's Database tool window.
