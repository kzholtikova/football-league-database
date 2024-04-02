USE football_system;

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
   