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
    AND station IN ('absolute80s','smooth80s')
    AND match_score IS null
ORDER BY id;

UPDATE matches SET matched_source = 'wantlist'
WHERE
    AND station IN ('absolute80s','smooth80s')
    AND id IN (9427,9456,9457);

UPDATE matches
SET matched_source = 'collection'
WHERE
    AND station IN ('absolute80s','smooth80s')
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
