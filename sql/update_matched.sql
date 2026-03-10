INSERT INTO matched (artist, title, matched_source)
SELECT
    distinct
    m.artist,
    m.title,
    m.matched_source
FROM matches m
WHERE
    NOT EXISTS (
    SELECT 1
        FROM matched d
        WHERE d.artist  = m.artist
          AND d.title   = m.title
)
AND (m.match_score < 100 
OR   m.match_score is NULL)
and  m.matched_source is not null
;

.mode csv
.echo off
.output data/matched/matched.csv

SELECT 
    artist,
    title,
    matched_source 
from matched
order by
    artist,
    title,
    matched_source
;

.output
.echo on
.mode column
