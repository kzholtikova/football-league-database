USE football_system;

CREATE TABLE unindexed_teams LIKE teams;
INSERT INTO unindexed_teams SELECT * FROM teams;

SELECT COUNT(1) FROM unindexed_teams;
SELECT COUNT(1) FROM indexed_teams;
SELECT COUNT(1) FROM indexed_teams2;

-- INDEX ON LEAGUE_ID
CREATE TABLE indexed_teams LIKE teams;
INSERT INTO indexed_teams SELECT * FROM unindexed_teams;
CREATE INDEX idx_league_id ON indexed_teams (league_id);

-- Unindexed (league_id)
SELECT t.name, l.name
FROM unindexed_teams t
     JOIN leagues l on l.id = t.league_id
WHERE league_id = 3
ORDER BY t.name;

# -> Sort: t.`name`  (cost=1.37e+6 rows=10.2e+6) (actual time=83949..84779 rows=7e+6 loops=1)
#     -> Index lookup on t using league_id (league_id=3)  (cost=1.37e+6 rows=10.2e+6) (actual time=0.193..71096 rows=7e+6 loops=1)

-- Indexed (league_id)
SELECT t.name, l.name
FROM indexed_teams t
    JOIN leagues l on l.id = t.league_id
WHERE league_id = 3
ORDER BY t.name;

# -> Sort: t.`name`  (cost=1.39e+6 rows=10.4e+6) (actual time=30791..31334 rows=7e+6 loops=1)
#     -> Index lookup on t using idx_league_id (league_id=3)  (cost=1.39e+6 rows=10.4e+6) (actual time=2.53..22409 rows=7e+6 loops=1)

# INDEX ON CITY
CREATE TABLE indexed_teams2 LIKE teams;
INSERT INTO indexed_teams2 SELECT * FROM unindexed_teams;
CREATE INDEX idx_teams_city ON indexed_teams2 (city);

-- Unindexed (city)
SELECT t.name
FROM unindexed_teams t
WHERE t.city = 'Madrid';

# -> Filter: (t.city = 'Madrid')  (cost=2.16e+6 rows=2.04e+6) (actual time=31.6..63332 rows=2 loops=1)
#     -> Table scan on t  (cost=2.16e+6 rows=20.4e+6) (actual time=27.7..62017 rows=21e+6 loops=1)

-- Indexed (city)
SELECT t.name
FROM indexed_teams2 t
WHERE t.city = 'Madrid';

# -> Filter: (t.city = 'Madrid')  (cost=2.2 rows=2) (actual time=5.48..5.51 rows=2 loops=1)
#     -> Index lookup on t using idx_teams_city (city='Madrid')  (cost=2.2 rows=2) (actual time=5.13..5.16 rows=2 loops=1)
