DROP TABLE IF EXISTS priority_list;

CREATE TABLE IF NOT EXISTS priority_list 
    (id INTEGER PRIMARY KEY AUTOINCREMENT,
     artist,
     title,
     play_date
    );

DROP VIEW IF EXISTS v_absolute80s_wantlist;

CREATE VIEW IF NOT EXISTS v_absolute80s_wantlist
AS
SELECT
    artist,
    title,
    date(play_datetime) AS play_date
FROM v_playlists
WHERE
    country = 'uk'
    AND station = 'absolute80s'
    AND matched_source = 'wantlist'
    and artist||title not in (select artist||title from priority_list);

DROP VIEW IF EXISTS v_min_playlist_wantdate;

CREATE VIEW IF NOT EXISTS v_min_playlist_wantdate
AS
SELECT
    play_date,
    count(*) AS play_count
FROM v_absolute80s_wantlist
WHERE play_date NOT IN (SELECT play_date FROM priority_list)
GROUP BY play_date ORDER BY play_count, play_date LIMIT 1;

INSERT INTO priority_list (artist, title, play_date)
SELECT
    a.artist,
    a.title,
    a.play_date
FROM v_absolute80s_wantlist a
WHERE
    a.play_date IN (SELECT m.play_date FROM v_min_playlist_wantdate m)
    AND a.artist || a.title NOT IN (SELECT p.artist || p.title FROM priority_list p)
ORDER BY artist, title
;

SELECT  id as "ID",
        artist as "Artist",
        title as "Title",
        play_date AS "Date"
FROM priority_list;

select 
CASE 
    WHEN artist LIKE 'THE %' THEN 
        REPLACE(SUBSTR(artist, 5), ' and ', ' & ')
    ELSE
        REPLACE(artist, ' and ', ' & ')
END AS "Artist",
        title as "Title"
FROM priority_list
order by id;
