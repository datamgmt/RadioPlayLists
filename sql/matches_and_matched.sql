drop table if exists matched;

CREATE TABLE if not exists matched(
  country TEXT,
  station TEXT,
  artist TEXT,
  title TEXT,
  matched_source
);

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
AND station = 'absolute80s'
;

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
AND station = 'absolute70s'
AND match_score < 100
;


.headers on
.mode csv
.echo off
.output matched.csv

SELECT * 
 from matched
 order by
     country,
     station,
     artist,
     title,
     matched_source;

.output
.echo on
.quit

SELECT *
FROM matches m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched d
    WHERE d.country = m.country
      AND d.station = m.station
      AND d.artist  = m.artist
      AND d.title   = m.title
);

SELECT artist, matched_artist, title, matched_title
FROM matches m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched d
    WHERE d.country = m.country
      AND d.station = m.station
      AND d.artist  = m.artist
      AND d.title   = m.title
) and station = 'absolute70s' and match_score is not null
order by artist, title;