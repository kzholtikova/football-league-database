USE football_system;

-- ASSIGNMENT 1
-- matches with dry-outs
SELECT m.id, CONCAT(COUNT(g.id), ':', 0) score
FROM goal g
    JOIN attendee a on a.id = g.attendee_id
    JOIN football_match m on m.id = a.match_id
GROUP BY a.match_id
HAVING COUNT(DISTINCT g.attendee_id) <= 1;

-- leagues ranking
SELECT l.name, SUM(s.points) total_points, SUM(goals_for) - SUM(goals_against) goals_difference
FROM standing s
    JOIN team t on t.id = s.team_id
    JOIN league l on l.id = t.league_id
GROUP BY l.id
ORDER BY total_points DESC, goals_difference DESC;

-- matches with the majority goals made in the 2nd halftime
SELECT m.name, SUM(g.time >= TIME('00:45:00')) second_half_goals, COUNT(g.id) total_goals
FROM goal g
    JOIN attendee a on a.id = g.attendee_id
    JOIN football_match m on m.id = a.match_id
GROUP BY a.match_id
HAVING second_half_goals > total_goals / 2
ORDER BY total_goals DESC, second_half_goals DESC

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
