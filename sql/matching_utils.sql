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
) AND station IN (SELECT station FROM stations WHERE validated = 'Y');

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
    AND station IN (SELECT station FROM stations WHERE validated = 'Y')
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
    AND station IN (SELECT station FROM stations WHERE validated = 'Y')
    AND match_score IS null
    AND matched_artist IS null
    AND matched_title IS null
    AND match_score IS null
ORDER BY id, station, artist, title, matched_source;


UPDATE matches SET matched_source = 'wantlist'
WHERE
    station IN (SELECT station FROM stations WHERE validated = 'Y')
    AND id IN (###)
    AND id < 25000;

UPDATE matches
SET matched_source = 'no single'
WHERE
    station IN (SELECT station FROM stations WHERE validated = 'Y')
    AND id IN (###)
    AND id < 25000;

UPDATE matches
SET matched_source = 'collection'
WHERE
    station IN (SELECT station FROM stations WHERE validated = 'Y')
    AND matched_source IS null
    AND id < 25000;

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
    = (
        SELECT d.matched_source
        FROM matched AS d
        WHERE
            d.artist = matches.artist
            AND d.title = matches.title
    )

SELECT
    sc.artist,
    sc.title,
    sc.play_count
FROM song_counts AS sc
WHERE
    sc.station = 'absolute80s'
    AND EXISTS (
        SELECT 1
        FROM matched AS m
        WHERE
            sc.artist = m.artist
            AND sc.title = m.title
            AND m.matched_source = 'wantlist'
    )
ORDER BY sc.play_count;