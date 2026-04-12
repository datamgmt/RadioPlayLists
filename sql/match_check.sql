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

SELECT
    country,
    station,
    matched_source,
    COUNT(play_count) AS title_count,
    CAST(
        ROUND(
            100.0 * COUNT(play_count)
            / SUM(COUNT(play_count)) OVER(PARTITION BY station),
            1
        ) AS REAL
    ) AS title_count_percentage,
    SUM(play_count) AS play_count,
    CAST(
        ROUND(
            100.0 * SUM(play_count)
            / SUM(SUM(play_count)) OVER(PARTITION BY station),
            1
        ) AS REAL
    ) AS play_count_percentage
FROM v_analysis
GROUP BY
    country,
    station,
    matched_source;
