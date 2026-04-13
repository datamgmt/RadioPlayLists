SELECT
    artist,
    title,
    COUNT(*) AS play_count
FROM playlists
WHERE
    country = 'uk'
    AND station = 'absolute80s'
GROUP BY
    artist,
    title
ORDER BY play_count DESC;

SELECT
    p.artist,
    p.title,
    m.matched_source,
    COUNT(p.artist) AS play_count
FROM playlists AS p,
    matched AS m
WHERE
    p.artist = m.artist
    AND p.title = m.title
    AND p.country = 'uk'
    AND p.station = 'absolute80s'
GROUP BY
    p.artist,
    p.title,
    m.matched_source
ORDER BY
    play_count ASC;

SELECT
    p.artist,
    p.title,
    m.matched_source,
    COUNT(p.artist) AS play_count
FROM playlists AS p,
    matched AS m
WHERE
    p.artist = m.artist
    AND p.title = m.title
    AND p.country = 'uk'
    AND p.station = 'absolute80s'
    AND m.matched_source = 'wantlist'
GROUP BY
    p.artist,
    p.title,
    m.matched_source
ORDER BY
    play_count ASC;

SELECT
    artist,
    title,
    play_count
FROM v_analysis
WHERE
    station = 'absolute80s'
    AND matched_source = 'collection'
    AND play_count > (
        SELECT MAX(play_count)
        FROM v_analysis
        WHERE
            matched_source = 'wantlist'
            AND station = 'absolute80s'
    )
ORDER BY play_count DESC, artist ASC, title ASC;
