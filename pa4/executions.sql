use football_system;

SET @current_season = 'Spring 2023';
CALL teams_by_season(@current_season, @teams_in_season);
SELECT @teams_in_season, @current_season;

-- teams_by_season validation
SELECT COUNT(DISTINCT a.team_id) teams_num
FROM attendees a
     JOIN matches m on m.id = a.match_id
     JOIN match_days md on md.id = m.match_day_id
     JOIN seasons s on s.id = md.season_id
WHERE s.name = 'Fall 2023';
