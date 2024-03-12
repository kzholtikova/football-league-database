USE football_system;

SELECT COUNT(1) FROM teams;
SELECT COUNT(1) FROM indexed_teams;

CREATE TABLE indexed_teams LIKE teams;
INSERT INTO indexed_teams SELECT * FROM teams;
CREATE INDEX idx_league_id ON indexed_teams (league_id);

-- WITHOUT INDEX
SELECT t.name, l.name
FROM teams t, leagues l
WHERE league_id = 3 AND l.id = league_id
ORDER BY t.name;

-- WITH INDEX
SELECT t.name, l.name
FROM indexed_teams t, leagues l
WHERE league_id = 3 AND l.id = league_id
ORDER BY t.name;
