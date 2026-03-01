DROP TABLE IF EXISTS song_counts;

CREATE TABLE song_counts AS
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
