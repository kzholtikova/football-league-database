## Description
A relational database for a football league system. A football league system is a hierarchy of leagues that compete in the same sport. Each league has several teams that play against each other in a round-robin format. Points rank the teams, goal difference, and goals scored. The top teams of each league may be promoted to a higher league, while the bottom teams may be relegated to a lower league. 

## Tables
* `teams`: Stores information about each team in the league system, such as name, city, stadium, and manager.<br>
* `players`: Stores information about each player who belongs to one or more teams in the league system, such as name, birthdate, nationality, and number.<br>
* `team_squads`: Junction table that ties together teams and players. Establishes many-to-many relationship.<br>
* `seasons`: Describes seasons, has attributes such as name ('Summer 2023') and start date.<br>
* `leagues`: Describes leagues, has the following attributes: name, number of teams.<br>
* `match_days`: Stores information about every match day for every league during every season.<br>
* `matches`: Stores information about each match that is played between two teams in the league system, such as datetime, venue, and match day.<br>
* `attendees`: Ties together teams and matches. Establishes many-to-many relationships. Holds information about was a team playing at home and whether they won the match.<br>
* `goals`: Stores information about each goal that is scored in a match, such as time, player, and attendee.<br>
* `standings`: Stores information about every team's results in every league after every match day. Contains the following attributes: match day, team, points (won = 3, drawn = 1, lost = 0), played, won, drawn, lost, goals_for, goals_against. <br>

## Diagram
![football_system](https://github.com/x01-software-engineering/dbe-assignment-01-kzholtikova/assets/145042018/b9daccf6-d97e-4a1c-a2bf-1bcacb570d11)
