WITH song_counts AS (
    SELECT
        country,
        station,
        artist,
        title,
        COUNT(*) AS play_count,
        ROW_NUMBER() OVER (
            PARTITION BY country, station
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM playlists
    GROUP BY
        country,
        station,
        artist,
        title
)
SELECT
    country,
    station,
    artist,
    title,
    play_count
FROM song_counts
WHERE rn <= 10
ORDER BY
    country,
    station,
    play_count DESC;