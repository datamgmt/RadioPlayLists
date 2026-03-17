INSERT INTO song_counts (
    country,
    station,
    artist,
    title,
    play_count
)
SELECT
    country,
    station,
    artist,
    title,
    COUNT(*) AS play_count
FROM playlists
GROUP BY
    country,
    station,
    artist,
    title
ORDER BY
    play_count DESC;
