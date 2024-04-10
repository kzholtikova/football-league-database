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

-- update attendees table to define match winner based on number of goals scored
CREATE PROCEDURE football_system.define_match_winner(IN match_name TEXT)
BEGIN 
    START TRANSACTION;
        SET @match_id = (SELECT id FROM matches m WHERE name =  match_name);
        IF @match_id IS NULL or (SELECT COUNT(1) FROM attendees a WHERE a.match_id = @match_id) != 2 THEN
            ROLLBACK;
            SELECT 'Invalid match id or attendees data' AS message;
        END IF;

        SET @max_scored = (SELECT MAX(goals.scored) 
                           FROM (SELECT COUNT(g.id) scored
                           FROM goals g
                                JOIN attendees a ON a.id = g.attendee_id
                           WHERE a.match_id = @match_id
                           GROUP BY team_id) goals);
    
        UPDATE attendees a
        SET is_winner = (SELECT COUNT(1) FROM goals g WHERE attendee_id = a.id) = @max_scored
        WHERE match_id = @match_id;
    COMMIT;
END $$

DELIMITER ;
    