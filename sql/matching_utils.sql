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
    AND station IN ('absolute80s','smooth80s','heart80s')
    AND match_score IS null
ORDER BY id;

UPDATE matches SET matched_source = 'wantlist'
WHERE
    station IN ('absolute80s','smooth80s','heart80s')
    AND id IN (1,2,3);

UPDATE matches
SET matched_source = 'collection'
WHERE
    station IN ('absolute80s','smooth80s','heart80s')
    AND matched_source IS null;

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
        

