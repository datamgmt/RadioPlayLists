SELECT
    artist,
    title,
    COUNT(*) AS play_count
FROM playlists
WHERE country = 'uk'
  AND station = 'absolute80s'
GROUP BY artist, title
ORDER BY play_count DESC;