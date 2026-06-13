DROP TABLE IF EXISTS priority_list;

CREATE TABLE IF NOT EXISTS priority_list 
    (id INTEGER PRIMARY KEY AUTOINCREMENT,
     artist,
     title,
     play_date
    );

INSERT INTO priority_list (artist, title, play_date)
SELECT
    a.artist,
    a.title,
    a.play_date
FROM (
    SELECT
        artist,
        title,
        date(play_datetime) AS play_date
    FROM v_playlists
    WHERE
        country = 'uk'
        AND station = 'absolute80s'
        AND matched_source = 'wantlist'
        AND artist || title NOT IN (SELECT artist || title FROM priority_list)
) AS a
WHERE
    a.play_date IN (SELECT m.play_date FROM (SELECT
        play_date,
        count(*) AS play_count
    FROM (
        SELECT
            artist,
            title,
            date(play_datetime) AS play_date
        FROM v_playlists
        WHERE
            country = 'uk'
            AND station = 'absolute80s'
            AND matched_source = 'wantlist'
            AND artist
            || title NOT IN (SELECT artist || title FROM priority_list
            )
    )
    WHERE play_date NOT IN (SELECT play_date FROM priority_list)
    GROUP BY play_date ORDER BY play_count, play_date LIMIT 1) AS m)
    AND a.artist
    || a.title NOT IN (SELECT p.artist || p.title FROM priority_list AS p)
ORDER BY a.artist, a.title;

SELECT
    id,
    CASE
        WHEN artist LIKE 'THE %'
            THEN
                replace(substr(artist, 5), ' and ', ' & ')
        ELSE
            replace(artist, ' and ', ' & ')
    END AS artist,
    title,
    play_date
FROM priority_list
ORDER BY id;
