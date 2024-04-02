use football_system;

DROP PROCEDURE IF EXISTS teams_by_season;
DROP PROCEDURE IF EXISTS define_match_winner;

DELIMITER $$

-- number of teams in the current season
CREATE PROCEDURE football_system.teams_by_season(INOUT current_season TEXT, INOUT teams_num INT)
BEGIN
    SET @season_id = 0;
    SELECT s.name, s.id INTO current_season, @season_id
    FROM seasons s
    ORDER BY s.start_date DESC
    LIMIT 1;
    
    SELECT COUNT(DISTINCT a.team_id) INTO teams_num
    FROM attendees a
        JOIN matches m on m.id = a.match_id
        JOIN match_days md on md.id = m.match_day_id
    WHERE md.season_id = @season_id; 
END $$

DELIMITER ;
    