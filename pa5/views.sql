use football_system;

CREATE OR REPLACE VIEW team_standing AS
SELECT RANK() over (ORDER BY SUM(season_points) DESC, SUM(season_goals - season_goals_against) DESC) team_rank, t.name team_name, 
       CONCAT(SUM(season_goals), ':', SUM(season_goals_against)) total_score, 
       GROUP_CONCAT(CONCAT(s.name, ' (', season_points, ')') ORDER BY s.start_date DESC SEPARATOR ', ') AS season_points
FROM (SELECT team_id, season_id, SUM(points) season_points, SUM(goals_for) season_goals, SUM(goals_against) season_goals_against
      FROM standings st
          JOIN match_days md on st.match_day_id = md.id
      GROUP BY team_id, season_id) ts
          JOIN seasons s on ts.season_id = s.id
          RIGHT JOIN teams t on t.id = ts.team_id
GROUP BY t.id
ORDER BY team_rank;

-- teams standing across all matches 
SELECT *
FROM team_standing;

-- top 5 teams
SELECT team_name 
FROM team_standing
LIMIT 5;

-- teams with no matches yet
SELECT team_name
FROM team_standing
WHERE season_points IS NULL;
