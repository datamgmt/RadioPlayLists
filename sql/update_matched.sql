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
AND (match_score < 100 
OR  match_score is NULL)
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
     matched_source
;

.output
.echo on
.mode column
