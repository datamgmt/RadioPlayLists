drop table if exists matched;

CREATE TABLE if not exists matched(
  country TEXT,
  station TEXT,
  artist TEXT,
  title TEXT,
  matched_source TEXT
);

.headers on
.mode csv
.import --skip 1 data/matched/matched.csv matched
.mode column

INSERT INTO matched (country, station, artist, title, matched_source)
SELECT m.country,
       m.station,
       m.artist,
       m.title,
       m.matched_source
FROM matches m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched d
    WHERE d.country = m.country
      AND d.station = m.station
      AND d.artist  = m.artist
      AND d.title   = m.title
)
AND match_score = 100
;