.mode csv
.echo off
.output data/wantlist.csv

SELECT DISTINCT
    artist AS Artist,
    title AS Title
FROM matched
WHERE matched_source = 'wantlist' 
ORDER BY artist,title;

.output
.echo on
.mode column
