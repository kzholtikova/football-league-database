USE football_system;

CREATE TABLE unindexed_teams LIKE teams;
INSERT INTO unindexed_teams SELECT * FROM teams;

SELECT COUNT(1) FROM unindexed_teams;
SELECT COUNT(1) FROM indexed_teams;
SELECT COUNT(1) FROM indexed_teams2;
SELECT COUNT(1) FROM attendees1;
SELECT COUNT(1) FROM attendees2;

CREATE TABLE attendees1 (
       id INT AUTO_INCREMENT PRIMARY KEY,
       match_id INT,
       team_id INT,
       is_home BOOLEAN NOT NULL,
       is_winner BOOLEAN,
       FOREIGN KEY (match_id) REFERENCES matches(id),
       FOREIGN KEY (team_id) REFERENCES unindexed_teams(id)
);

CREATE TABLE attendees2 (
       id INT AUTO_INCREMENT PRIMARY KEY,
       match_id INT,
       team_id INT,
       is_home BOOLEAN NOT NULL,
       is_winner BOOLEAN,
       FOREIGN KEY (match_id) REFERENCES matches(id),
       FOREIGN KEY (team_id) REFERENCES indexed_teams2(id)
);

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
    
    
-- Unindexed (city) query 2
SELECT t.id, t.city
FROM football_system.attendees1 a
    JOIN unindexed_teams t on t.id = a.team_id
WHERE is_winner AND t.city = 'Ma%';

# -> Nested loop inner join  (cost=1.17e+6 rows=99826) (actual time=9127..9127 rows=0 loops=1)
#     -> Filter: (a.team_id is not null)  (cost=101845 rows=998256) (actual time=1.8..260 rows=1e+6 loops=1)
#         -> Covering index scan on a using team_id  (cost=101845 rows=998256) (actual time=1.74..206 rows=1e+6 loops=1)
#     -> Filter: (t.city = 'Ma%')  (cost=0.974 rows=0.1) (actual time=0.00879..0.00879 rows=0 loops=1e+6)
#         -> Single-row index lookup on t using PRIMARY (id=a.team_id)  (cost=0.974 rows=1) (actual time=0.0086..0.00862 rows=1 loops=1e+6)

-- Indexed (city) query 2
SELECT t.id, t.city
FROM attendees2 a
     JOIN indexed_teams2 t on t.id = a.team_id
WHERE is_winner AND t.city = 'Ma%';

# -> Nested loop inner join  (cost=2.21 rows=1.09) (actual time=0.154..0.154 rows=0 loops=1)
#     -> Filter: (t.city = 'Ma%')  (cost=1.1 rows=1) (actual time=0.14..0.14 rows=0 loops=1)
#         -> Index lookup on t using idx_teams_city (city='Ma%')  (cost=1.1 rows=1) (actual time=0.14..0.14 rows=0 loops=1)
#     -> Covering index lookup on a using team_id (team_id=t.id)  (cost=1.11 rows=1.09) (never executed)

-- Unindexed (city) query 3
EXPLAIN ANALYZE
SELECT t.id, t.city
FROM football_system.attendees1 a
     JOIN unindexed_teams t on t.id = a.team_id
WHERE is_winner AND t.city = '%or%';

-- Indexed (city) query 3
EXPLAIN ANALYZE
SELECT t.id, t.city
FROM attendees2 a
     JOIN indexed_teams2 t on t.id = a.team_id
WHERE is_winner AND t.city = '%or%';