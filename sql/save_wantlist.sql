.echo off
.mode column
.output data/wishlist-by-artist.txt

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
    sc.title asc,
    sc.play_count desc;
    
.output


.output data/wishlist-by-playcount.txt

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
    sc.play_count desc,
    (CASE WHEN sc.artist LIKE 'The %' THEN SUBSTR(sc.artist, 5) ELSE sc.artist END),
    sc.title asc;
    
.output

.output data/wishlist-by-priority.txt

select  artist, 
        title, 
        count(*) play_count from v_playlists
where   country = 'uk'
and     station = 'absolute80s'
and     matched_source = 'wantlist'
and date(play_datetime) in (
SELECT  date(play_datetime) play_date
from    v_playlists
where   country = 'uk'
and     station = 'absolute80s'
group by play_date
having 100.0*sum(matched_source='wantlist')/sum(1) < 3
and sum(matched_source='wantlist') < 6)
group by artist, title;

.output

.mode column
.echo on
