USE football_system;

SELECT COUNT(1) FROM teams;
SELECT COUNT(1) FROM indexed_teams;
SELECT COUNT(1) FROM indexed_teams2;

-- INDEX ON FOREIGN KEY
CREATE TABLE indexed_teams LIKE teams;
INSERT INTO indexed_teams SELECT * FROM teams;
CREATE INDEX idx_league_id ON indexed_teams (league_id);

SELECT t.name, l.name
FROM teams t
    JOIN leagues l on l.id = t.league_id
WHERE league_id < 3
ORDER BY t.name;

-- -> Sort: t.`name`  (cost=1.38e+6 rows=10.2e+6) (actual time=95975..96526 rows=7e+6 loops=1)
--    -> Index lookup on t using league_id (league_id=3)  (cost=1.38e+6 rows=10.2e+6) (actual time=1.33..85763 rows=7e+6 loops=1)

SELECT t.name, l.name
FROM indexed_teams t
    JOIN leagues l on l.id = t.league_id
WHERE league_id < 3
ORDER BY t.name;

-- -> Sort: t.`name`  (cost=1.39e+6 rows=10.4e+6) (actual time=29294..29861 rows=7e+6 loops=1)
--    -> Index lookup on t using idx_league_id (league_id=3)  (cost=1.39e+6 rows=10.4e+6) (actual time=3.76..22074 rows=7e+6 loops=1)


-- INDEX ON CITY
CREATE TABLE indexed_teams2 LIKE teams;
INSERT INTO indexed_teams2 SELECT * FROM teams;
CREATE INDEX idx_teams_city ON indexed_teams2 (city);

SELECT t.id, t.city FROM teams t WHERE city = 'Madrid';

# -> Filter: (t.city = 'Madrid')  (cost=2.16e+6 rows=2.04e+6) (actual time=11019..11019 rows=0 loops=1)
#     -> Table scan on t  (cost=2.16e+6 rows=20.4e+6) (actual time=14.1..9869 rows=21e+6 loops=1)

SELECT t.id, t.city FROM indexed_teams2 t WHERE city = 'Madrid';

# -> Filter: (t.city = 'Madrid')  (cost=1.1 rows=1) (actual time=0.0798..0.0798 rows=0 loops=1)
#     -> Index lookup on t using idx_teams_city (city='New York')  (cost=1.1 rows=1) (actual time=0.0791..0.0791 rows=0 loops=1)
