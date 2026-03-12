SELECT
    id,
    artist,
    title,
    country,
    station,
    play_count,
    match_score,
    matched_source,
    matched_artist,
    matched_title,
    match_note
FROM matches AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched AS d
    WHERE
        d.artist = m.artist
        AND d.title = m.title
) AND station = 'absolute80s';

SELECT
    id,
    station,
    artist,
    matched_artist,
    title,
    matched_title,
    matched_source,
    match_score
FROM matches AS m
WHERE
    NOT EXISTS (
        SELECT 1
        FROM matched AS d
        WHERE
            d.artist = m.artist
            AND d.title = m.title
    )
    AND station IN ('absolute80s','smooth80s','heart80s','absolute70s')
    AND match_score IS null
ORDER BY id;

SELECT
    id,
    station,
    artist,
    title,
    matched_source
    FROM matches AS m
WHERE
    NOT EXISTS (
        SELECT 1
        FROM matched AS d
        WHERE
            d.artist = m.artist
            AND d.title = m.title
    )
    AND station IN ('absolute80s','smooth80s','heart80s','absolute70s')
    AND match_score IS NULL
    AND matched_artist IS NULL
    AND matched_title IS NULL
    AND match_score is NULL
ORDER BY id, station, artist, title,matched_source;


UPDATE matches SET matched_source = 'wantlist'
WHERE
    station IN ('absolute80s','smooth80s','heart80s','absolute70s')
    AND id IN (1501,2136,2283,2444,2456,2638,3067,3071,3073,3389,3392,3753,4535,4537,5018,5019,5562,5563,6238,6243,6244)
    AND id <7000;

UPDATE matches
SET matched_source = 'no single'
WHERE
    station IN ('absolute80s','smooth80s','heart80s','absolute70s')
    AND id IN (4136,6239)
    AND id <7000;

UPDATE matches
SET matched_source = 'collection'
WHERE
    station IN ('absolute80s','smooth80s','heart80s','absolute70s')
    AND matched_source IS null
    AND id <7000;

 select station, matched_source, count(*) 
 from matches 
 where station IN ('absolute80s','smooth80s','heart80s','absolute70s') 
 group by station, matched_source;

SELECT
    id,
    artist,
    matched_artist,
    title,
    matched_title,
    matched_source,
    match_score
FROM matches AS m
WHERE
    EXISTS (
        SELECT 1
        FROM matched AS d
        WHERE
            d.artist = m.artist
            AND d.title = m.title
    ) AND matched_source IS null
ORDER BY id;

UPDATE matches
SET
    matched_source
    = (SELECT d.matched_source
    FROM matched AS d
    WHERE
        d.artist = matches.artist
        AND d.title = matches.title)
        

