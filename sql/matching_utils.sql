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

UPDATE matches
SET matched_source = 'no single'
WHERE
    station IN (SELECT station FROM stations WHERE validated = 'Y')
    AND matched_source IS null
    AND id IN (###);
    
UPDATE matches SET matched_source = 'collection'
WHERE
    station IN (SELECT station FROM stations WHERE validated = 'Y')
    AND matched_source IS null
    AND id IN (###);

UPDATE matches
SET matched_source = 'wantlist'
WHERE
    station IN (SELECT station FROM stations WHERE validated = 'Y')
    AND matched_source IS null;

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
    
--- Complete a date

SELECT
    p.play_datetime, 
    p.artist, 
    p.title, 
    a.matched_source 
from 
    v_playlists p,
    v_analysis a 
where   p.station = 'absolute80s' 
and     a.station = p.station 
and     a.artist = p.artist 
and     a.title = p.title 
and     a.matched_source = 'wantlist'
and     date(play_datetime) in (select playdate
from
(
select distinct artist, title, date(play_datetime) playdate 
FROM V_PLAYLISTS 
where station = 'absolute80s' and matched_source = 'wantlist'
) group by playdate
having count(*) < 10)
order by 2,3,1;

SELECT distinct
    p.artist, 
    p.title
from 
    v_playlists p,
    v_analysis a 
where   p.station = 'absolute80s' 
and     a.station = p.station 
and     a.artist = p.artist 
and     a.title = p.title 
and     a.matched_source = 'wantlist'
and     date(play_datetime) in (select playdate
from
(
select distinct artist, title, date(play_datetime) playdate 
FROM V_PLAYLISTS 
where station = 'absolute80s' and matched_source = 'wantlist'
) group by playdate
having count(*) < 10)
order by 1,2;

SELECT distinct
    date(p.play_datetime), 
    p.artist, 
    p.title, 
    a.matched_source 
from 
    v_playlists p,
    v_analysis a 
where   p.station = 'absolute80s' 
and     a.station = p.station 
and     a.artist = p.artist 
and     a.title = p.title 
and     a.matched_source = 'wantlist'
and     date(play_datetime) in (select playdate
from
(
select distinct artist, title, date(play_datetime) playdate 
FROM V_PLAYLISTS 
where station = 'absolute80s' and matched_source = 'wantlist'
) group by playdate
having count(*) < 10)
order by 1,2,3;
