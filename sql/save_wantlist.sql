.echo off
.mode column
.output data/wishlist.txt

SELECT
    (CASE WHEN sc.artist LIKE 'The %' THEN SUBSTR(sc.artist, 5) ELSE sc.artist END) AS artist,
    sc.title,
    sc.play_count
FROM song_counts AS sc
WHERE
    sc.station = 'absolute80s'
    AND EXISTS (
        SELECT 1
        FROM matched AS m
        WHERE
            (CASE WHEN sc.artist LIKE 'The %' THEN SUBSTR(sc.artist, 5) ELSE sc.artist END) =
            (CASE WHEN m.artist LIKE 'The %' THEN SUBSTR(m.artist, 5) ELSE m.artist END)
            AND sc.title = m.title
            AND m.matched_source = 'wantlist'
    )
ORDER BY
    (CASE WHEN sc.artist LIKE 'The %' THEN SUBSTR(sc.artist, 5) ELSE sc.artist END),
    sc.play_count desc;
    
.output
.mode column
.echo on
