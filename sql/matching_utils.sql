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
);

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
    AND station = 'absolute80s'
    AND match_score IS null
ORDER BY id;

UPDATE matches SET matched_source = 'wantlist'
WHERE
    station = 'absolute80s'
    AND id IN (546, 548, 712, 722, 723, 905, 907, 910, 911, 917);

UPDATE matches
SET matched_source = 'collection'
WHERE
    station = 'absolute80s'
    AND matched_source IS null
    AND id < 100;


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

UPDATE matches m
SET
    matched_source
    = SELECT d.matched_source
    FROM matched AS d
    WHERE
        d.artist = m.artist
        AND d.title = m.title
