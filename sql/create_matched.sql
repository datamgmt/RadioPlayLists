drop table if exists matched;

CREATE TABLE if not exists matched(
  artist TEXT,
  title TEXT,
  matched_source TEXT
);

.headers on
.mode csv
.import --skip 1 data/matched/matched.csv matched
.mode column

INSERT INTO matched (artist, title, matched_source)
SELECT m.artist,
       m.title,
       m.matched_source
FROM matches m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched d
    WHERE d.artist  = m.artist
      AND d.title   = m.title
)
AND match_score = 100
;