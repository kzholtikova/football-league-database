USE football_system;

INSERT INTO standings (match_day_id, team_id, points, played, won, drawn, lost, goals_for, goals_against)
SELECT
    match_day_id,
    team_id,
    SUM(points) AS total_points,
    COUNT(*) AS played,
    SUM(won) AS won,
    SUM(drawn) AS drawn,
    SUM(lost) AS lost,
    SUM(goals_for) AS goals_for,
    SUM(goals_against) AS goals_against
FROM (SELECT m.match_day_id, a.team_id,
        CASE
             WHEN a.is_winner = 1 THEN 3
             WHEN a.is_winner IS NULL THEN 1
             ELSE 0 END AS points,
         CASE WHEN a.is_winner = 1 THEN 1 ELSE 0 END AS won,
         CASE WHEN a.is_winner IS NULL THEN 1 ELSE 0 END AS drawn,
         CASE WHEN a.is_winner = 0 THEN 1 ELSE 0 END AS lost,
         COUNT(DISTINCT CASE WHEN g.attendee_id = a.id THEN g.id END) AS goals_for,
         (SELECT COUNT(DISTINCT g2.id)
            FROM matches m2
                JOIN attendees a2 ON m2.id = a2.match_id
                JOIN goals g2 ON g2.attendee_id = a2.id
                WHERE a2.team_id = a.team_id AND m2.match_day_id = m.match_day_id) AS goals_against
     FROM matches m
        JOIN attendees a ON m.id = a.match_id
        LEFT JOIN goals g ON g.attendee_id = a.id
     GROUP BY m.match_day_id, a.team_id, a.is_winner) AS subquery
GROUP BY match_day_id, team_id;
