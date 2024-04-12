use football_system;

CREATE INDEX idx_match_day_season ON match_days (id, season_id);

CREATE OR REPLACE VIEW team_standing AS
SELECT RANK() over (ORDER BY SUM(season_points) DESC, SUM(season_goals - season_goals_against) DESC) team_rank, t.name team_name,
       CONCAT(SUM(season_goals), ':', SUM(season_goals_against)) total_score,
       GROUP_CONCAT(CONCAT(s.name, ' (', season_points, ')') ORDER BY s.start_date DESC SEPARATOR ', ') AS points_by_season
FROM teams t
     LEFT JOIN (SELECT team_id, season_id, SUM(points) season_points, SUM(goals_for) season_goals, SUM(goals_against) season_goals_against
                FROM standings s
                     JOIN match_days md FORCE INDEX (idx_match_day_season) on s.match_day_id = md.id
                GROUP BY team_id, season_id) ts on t.id = ts.team_id
     LEFT JOIN seasons s on ts.season_id = s.id
GROUP BY t.id
ORDER BY team_rank;

-- global team ranking
EXPLAIN ANALYZE
SELECT *
FROM team_standing;

-- top 5 teams
EXPLAIN ANALYZE
SELECT team_name 
FROM team_standing
LIMIT 5;

-- teams with no matches yet
EXPLAIN ANALYZE
SELECT team_name
FROM team_standing ts
WHERE ts.points_by_season IS NULL;



CREATE INDEX idx_attendee_team ON attendees (id, team_id);

CREATE OR REPLACE VIEW strikers_stats AS
SELECT p.name player_name, total_goals, goals_by_team, goals_by_season
FROM players p
    LEFT JOIN (SELECT player_id, GROUP_CONCAT(CONCAT(t.name, ' (', team_goals, ')') ORDER BY team_goals SEPARATOR ', ') goals_by_team 
               FROM (SELECT player_id, team_id, COUNT(g.id) team_goals
                     FROM goals g
                        JOIN attendees a FORCE INDEX (idx_attendee_team) on g.attendee_id = a.id
                     GROUP BY player_id, team_id) tg
                    JOIN teams t on tg.team_id = t.id
               GROUP BY player_id) by_team on p.id = by_team.player_id
    LEFT JOIN (SELECT player_id, SUM(season_goals) total_goals, GROUP_CONCAT(CONCAT(s.name, ' (', season_goals, ')') ORDER BY s.start_date DESC SEPARATOR ', ') goals_by_season 
               FROM (SELECT player_id, season_id, COUNT(g.id) season_goals
                     FROM goals g
                        JOIN attendees a on g.attendee_id = a.id
                        JOIN matches m on a.match_id = m.id
                        JOIN match_days md FORCE INDEX (idx_match_day_season) on m.match_day_id = md.id
                     GROUP BY player_id, season_id) sg
                    JOIN seasons s on sg.season_id = s.id
               GROUP BY player_id) by_season ON p.id = by_season.player_id
ORDER BY total_goals DESC;

-- strikers goals distribution
EXPLAIN ANALYZE 
SELECT *
FROM strikers_stats;

-- amount of players with no goals scored so far
EXPLAIN ANALYZE
SELECT COUNT(1)
FROM strikers_stats
WHERE total_goals IS NULL;

-- strikers goal stats that have scored goals for more than 1 team (duals)
EXPLAIN ANALYZE
SELECT player_name, total_goals, goals_by_team
FROM strikers_stats
WHERE (LENGTH(goals_by_team) - LENGTH(REPLACE(goals_by_team, ', ', ''))) > 1
