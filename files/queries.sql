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

-- refactored
SELECT s.name, md.day_number, (SELECT COUNT(DISTINCT league_id) FROM teams t 
                               WHERE t.id IN (SELECT team_id FROM attendees a 
                                              WHERE a.match_id IN (SELECT id FROM matches m 
                                                                             WHERE m.match_day_id = md.id))) leagues_playing
FROM match_days md
    JOIN seasons s on s.id = md.season_id
GROUP BY season_id, md.id
HAVING leagues_playing = 1;
