USE football_system;

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