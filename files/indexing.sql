USE football_system;

CREATE TABLE indexed_standings LIKE standings;
INSERT INTO indexed_standings SELECT * FROM standings;

CREATE INDEX team_points_idx ON indexed_standings (team_id, points);

-- UNINDEXED
-- -> Table scan on <temporary>  (actual time=2.89..2.9 rows=28 loops=1)
--     -> Aggregate using temporary table  (actual time=2.89..2.89 rows=28 loops=1)
--         -> Nested loop inner join  (cost=21.4 rows=47) (actual time=1.75..2.46 rows=47 loops=1)
--             -> Table scan on standings  (cost=4.95 rows=47) (actual time=1.21..1.27 rows=47 loops=1)
--             -> Single-row covering index lookup on t using PRIMARY (id=standings.team_id)  (cost=0.252 rows=1) (actual time=0.0249..0.0249 rows=1 loops=47)

EXPLAIN ANALYZE
SELECT t.id, SUM(points)
FROM standings
    JOIN teams t on t.id = standings.team_id
GROUP BY team_id;

-- INDEXED
-- -> Group aggregate: sum(indexed_standings.points)  (cost=26.1 rows=28) (actual time=0.657..0.731 rows=28 loops=1)
--     -> Nested loop inner join  (cost=21.4 rows=47) (actual time=0.153..0.238 rows=47 loops=1)
--         -> Covering index scan on indexed_standings using team_points_idx  (cost=4.95 rows=47) (actual time=0.136..0.156 rows=47 loops=1)
--         -> Single-row covering index lookup on t using PRIMARY (id=indexed_standings.team_id)  (cost=0.252 rows=1) (actual time=0.00138..0.00142 rows=1 loops=47)

EXPLAIN ANALYZE
SELECT t.id, SUM(points)
FROM indexed_standings
    JOIN teams t on t.id = indexed_standings.team_id
GROUP BY team_id;
