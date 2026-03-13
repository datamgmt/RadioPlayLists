DROP TABLE IF EXISTS matched;

CREATE TABLE IF NOT EXISTS matched
(
    artist TEXT,
    title TEXT,
    matched_source TEXT
);

.headers on
.mode csv
.import --skip 1 data/matched/matched.csv matched
.mode column

INSERT INTO matched (artist, title, matched_source)
SELECT
    m.artist,
    m.title,
    m.matched_source
FROM matches AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched AS d
    WHERE
        d.artist = m.artist
        AND d.title = m.title
)
AND m.match_score = 100;


UPDATE matches
SET matched_source = 
(SELECT matched_source 
    FROM  matched m
    WHERE m.artist = matches.artist
    AND   m.title = matches.title
)
WHERE matched_source IS NULL;
