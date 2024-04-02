 USE football_system;

-- ASSIGNMENT 1
-- matches with dry-outs
SELECT m.id, CONCAT(COUNT(g.id), ':', 0) score
FROM goals g
    JOIN attendees a on a.id = g.attendee_id
    JOIN matches m on m.id = a.match_id
GROUP BY a.match_id
HAVING COUNT(DISTINCT g.attendee_id) <= 1;

-- leagues ranking
SELECT l.name, SUM(s.points) total_points, SUM(goals_for) - SUM(goals_against) goals_difference
FROM standings s
    JOIN teams t on t.id = s.team_id
    JOIN leagues l on l.id = t.league_id
GROUP BY l.id
ORDER BY total_points DESC, goals_difference DESC;

-- matches with the majority goals made in the 2nd halftime
SELECT m.name, SUM(g.time >= TIME('00:45:00')) second_half_goals, COUNT(g.id) total_goals
FROM goals g
    JOIN attendees a on a.id = g.attendee_id
    JOIN matches m on m.id = a.match_id
GROUP BY a.match_id
HAVING second_half_goals > total_goals / 2
ORDER BY total_goals DESC, second_half_goals DESC;

-- ADDITIONAL
-- players with avg goals scored per match greater than specific value
SELECT p.name, COUNT(g.id) / m.matches goals_per_match
FROM goals g
    JOIN players p on p.id = g.player_id
    JOIN (SELECT player_id, COUNT(DISTINCT a.match_id) matches
          FROM team_squads t
            JOIN attendees a on t.team_id = a.team_id
          GROUP BY player_id) m on g.player_id = m.player_id
GROUP BY g.player_id
HAVING goals_per_match > 1.5;


-- ASSIGNMENT 2
-- footballers playing for few teams
SELECT p.name, COUNT(DISTINCT team_id) teams_count
FROM team_squads ts
    JOIN players p on p.id = ts.player_id
GROUP BY player_id
HAVING teams_count > 1
ORDER BY teams_count DESC;

-- teams have played more matches at home stadium
SELECT t.name team_name, SUM(is_home = TRUE) home_matches
FROM attendees a
    JOIN teams t on t.id = a.team_id
GROUP BY team_id 
HAVING home_matches > SUM(is_home = FALSE)
ORDER BY home_matches DESC;

-- match days with the matches within 1 league
SELECT s.name, md.day_number, COUNT(DISTINCT league_id) leagues_playing
FROM attendees a
    JOIN football_system.teams t on t.id = a.team_id
    JOIN matches m on m.id = a.match_id 
    JOIN match_days md on md.id = m.match_day_id
    JOIN seasons s on s.id = md.season_id
GROUP BY season_id, match_day_id
HAVING leagues_playing = 1;

-- eliminated joins
SELECT s.name, md.day_number, (SELECT COUNT(DISTINCT league_id) FROM teams t 
                               WHERE t.id IN (SELECT team_id FROM attendees a 
                                              WHERE a.match_id IN (SELECT id FROM matches m 
                                                                             WHERE m.match_day_id = md.id))) leagues_playing
FROM match_days md
    JOIN seasons s on s.id = md.season_id
GROUP BY season_id, md.id
HAVING leagues_playing = 1;
   


-- ASSIGNMENT 3

-- SELECT NON-CORRELATED
-- league/s whose teams won the greatest num of matches
SELECT *
FROM leagues l
WHERE l.id = (SELECT league_id
              FROM attendees a
                       JOIN teams t on t.id = a.team_id
              WHERE a.is_winner
              GROUP BY league_id
              ORDER BY COUNT(a.id) DESC
              LIMIT 1);

-- players having birthday on start of one of the seasons
SELECT p.name, p.birthdate
FROM players p
WHERE p.birthdate IN (SELECT start_date
                      FROM seasons s);

-- teams playing only away
SELECT t.name
FROM teams t
WHERE t.id NOT IN (SELECT team_id
                   FROM attendees a
                   WHERE is_home);

-- show matches info if they're match days with no matches
SELECT m.name, m.venue, m.datetime
FROM matches m
WHERE EXISTS(SELECT 1
             FROM match_days md
             WHERE NOT EXISTS(SELECT 1
                              FROM matches m
                              WHERE m.match_day_id = md.id));


-- show all seasons if there's no season of the current year so far
SELECT *
FROM seasons s
WHERE NOT EXISTS(SELECT 1
                 FROM seasons s1
                 WHERE YEAR(s1.start_date) = YEAR(CURRENT_DATE));

-- SELECT CORRELATED
-- seasons having specific match days number
SELECT s.name
FROM seasons s
WHERE (SELECT COUNT(DISTINCT md.id)
       FROM match_days md
       WHERE md.season_id = s.id) = 5;

-- teams with Ukrainian players
SELECT t.name
FROM teams t
WHERE 'Ukraine' IN (SELECT p.nationality
                    FROM players p
                             JOIN team_squads ts on p.id = ts.player_id
                    WHERE ts.team_id = t.id);

-- matches with no teams from the league specified
SELECT m.name
FROM matches m
WHERE 1 NOT IN (SELECT DISTINCT league_id
                FROM attendees a
                         JOIN teams t on t.id = a.team_id
                WHERE a.match_id = m.id);

-- teams with French players
SELECT t.name
FROM teams t
WHERE EXISTS(SELECT 1
             FROM team_squads ts
                      JOIN players p on p.id = ts.player_id
             WHERE ts.team_id = t.id AND p.nationality = 'France');

-- teams without players having specified number
SELECT t.name
FROM teams t
WHERE NOT EXISTS(SELECT 1
                 FROM players p
                          JOIN team_squads ts on p.id = ts.player_id
                 WHERE ts.team_id = t.id AND p.number = 7);


-- UPDATE NON-CORRELATED
-- player who made the quickest goal ever
SELECT p.name
FROM players p
WHERE p.id = (SELECT player_id
              FROM goals g
              ORDER BY g.time DESC
              LIMIT 1);

-- assign teams got 0 points for all matches to the specified league 
UPDATE teams t
SET league_id = 3
WHERE t.id IN (SELECT team_id
               FROM standings s
               GROUP BY team_id
               HAVING SUM(points) = 0);

-- set match match_day_id to the specified value if it's not in the match_days table
UPDATE matches m
SET match_day_id = 1
WHERE match_day_id NOT IN (SELECT md.id FROM match_days md);

-- elaborate on stadium names if there're some in different cities having same names 
UPDATE teams t
SET t.stadium = CONCAT(t.stadium, t.city)
WHERE EXISTS(SELECT 1
             FROM (SELECT id, stadium, city FROM teams) AS t1
             WHERE t.id != t1.id AND t.stadium = t1.stadium AND t.city != t1.city);

-- assign drawn to 0 if there's no undefined is_winner
UPDATE standings s
SET drawn = 0
WHERE NOT EXISTS(SELECT 1
                 FROM attendees a
                 WHERE is_winner IS NULL);

-- UPDATE CORRELATED
-- update matches venues from specified season
UPDATE matches m
SET m.venue = 'Stadium'
WHERE (SELECT md.season_id
       FROM match_days md
       WHERE md.id = m.match_day_id) = 5;

-- elaborate on match name if it's La Liga in game
UPDATE matches m
SET m.name = CONCAT(m.name, ' - La Liga')
WHERE 2 IN (SELECT DISTINCT league_id
            FROM attendees a
                     JOIN teams t on t.id = a.team_id
            WHERE a.match_id = m.id);

-- equate won to 0 if team isn't in the match day winners list
UPDATE standings s
SET won = 0
WHERE s.team_id NOT IN (SELECT DISTINCT a.team_id
                        FROM attendees a
                                 JOIN matches m on m.id = a.match_id
                        WHERE s.match_day_id = m.match_day_id AND is_winner);

-- specify the captain role in player's name
UPDATE players p
SET p.name = CONCAT(p.name, ' (Captain)')
WHERE EXISTS(SELECT 1
             FROM team_squads ts
             WHERE ts.player_id = p.id AND ts.position = 'Captain');

-- set is_winner to null if the attendee hasn't scored any goals
UPDATE attendees a
SET is_winner = NULL
WHERE NOT EXISTS(SELECT 1
                 FROM goals g
                 WHERE a.id = g.attendee_id);


-- DELETE NON-CORRELATED
-- delete attendees related to the match with invalid timestamp
DELETE FROM attendees
WHERE match_id = (SELECT MIN(id) FROM matches WHERE datetime > NOW());

-- delete match if there're not exactly 2 attendee
DELETE FROM matches m
WHERE m.id IN (SELECT match_id
               FROM attendees a
               GROUP BY match_id
               HAVING COUNT(DISTINCT a.id) != 2);

-- delete leagues having 0 teams
DELETE FROM leagues l
WHERE l.id NOT IN (SELECT DISTINCT league_id
                   FROM teams);

-- clear team squads if there's a new decade season
DELETE FROM team_squads
WHERE EXISTS(SELECT 1
             FROM seasons s
             WHERE start_date > NOW() AND YEAR(start_date) % 10 = 0);

-- delete matches
DELETE FROM players p
WHERE NOT EXISTS(SELECT DISTINCT player_id
                 FROM team_squads);

-- DELETE CORRELATED
-- delete attendee if there's no second attendee for the match
DELETE FROM teams t
WHERE (SELECT COUNT(1)
       FROM team_squads ts
       WHERE ts.team_id = t.id) < 11;

-- delete teams with russian players
DELETE FROM teams t
WHERE 'Russian' IN (SELECT p.nationality
                    FROM players p
                             JOIN team_squads ts on p.id = ts.player_id
                    WHERE ts.team_id = t.id);

-- delete teams without any league
DELETE FROM teams t
WHERE league_id NOT IN (SELECT l.id FROM leagues l);

-- delete teams with minor players    
DELETE FROM teams t
WHERE EXISTS(SELECT 1
             FROM team_squads ts
                      JOIN players p ON ts.player_id = p.id
             WHERE ts.team_id = t.id AND p.birthdate > (NOW() - 18));

-- delete seasons without match days
DELETE FROM seasons s
WHERE NOT EXISTS(SELECT 1
                 FROM match_days md
                 WHERE md.season_id = s.id);

-- UNION / UNION ALL / INTERSECT / EXCEPT
-- retrieve all stadiums somehow related to league 3
SELECT t.stadium
FROM teams t
WHERE league_id = 3
UNION
SELECT m.venue
FROM attendees a
         JOIN matches m on m.id = a.match_id
         JOIN teams t on t.id = a.team_id
WHERE t.league_id = 3;

-- retrieve dual players and those from low performance teams
SELECT p.name
FROM team_squads ts
         JOIN players p on p.id = ts.player_id
GROUP BY player_id
HAVING COUNT(DISTINCT team_id) > 1
UNION ALL
SELECT p.name
FROM (SELECT t.id, SUM(goals_for) total_goals_scored
      FROM standings s
               JOIN teams t on t.id = s.team_id
      GROUP BY team_id
      HAVING SUM(points) = 0) low_performance_teams
         JOIN team_squads ts on ts.team_id = low_performance_teams.id
         JOIN players p on p.id = ts.player_id;

-- players from the league 1 that have scored goals
SELECT p.name
FROM players p
         JOIN team_squads ts on p.id = ts.player_id
         JOIN teams t on t.id = ts.team_id
WHERE t.league_id = 1
INTERSECT
SELECT p.name
FROM goals g
         JOIN players p on p.id = g.player_id;

-- teams that are still leading even if they haven't participated in any match this year yet 
(SELECT t.name
 FROM standings s
        JOIN teams t on t.id = s.team_id
 ORDER BY points DESC
 LIMIT 5)
EXCEPT
SELECT t.name
FROM attendees a
         JOIN matches m on m.id = a.match_id
         JOIN teams t on t.id = a.team_id
WHERE YEAR(m.datetime) = 23; 
