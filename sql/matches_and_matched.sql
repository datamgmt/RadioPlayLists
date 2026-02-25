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
AND match_score < 100
and matched_source is not null
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
and matched_source is not null
;

.mode csv
.echo off
.output data/matched/matched.csv

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
.mode column

.q

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

SELECT id, artist, matched_artist, title, matched_title
FROM matches m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched d
    WHERE d.country = m.country
      AND d.station = m.station
      AND d.artist  = m.artist
      AND d.title   = m.title
) and station = 'absolute70s' and match_score is null
order by artist, title;