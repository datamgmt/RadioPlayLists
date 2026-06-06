DROP TABLE IF EXISTS sqlean_define;

CREATE TABLE IF NOT EXISTS sqlean_define (
    name TEXT,
    type TEXT,
    body TEXT,
    PRIMARY KEY (name)
);

DROP TABLE IF EXISTS stations;

CREATE TABLE IF NOT EXISTS stations (
    country TEXT NOT NULL,
    station TEXT NOT NULL,
    url TEXT NOT NULL,
    music_tags TEXT NOT NULL,
    validated TEXT,
    PRIMARY KEY (country, station)
);

# DROP TABLE IF EXISTS playlists;

CREATE TABLE IF NOT EXISTS playlists (
    country TEXT NOT NULL,
    station TEXT NOT NULL,
    play_date TEXT NOT NULL,
    play_time TEXT NOT NULL,
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    PRIMARY KEY (country, station, play_date, play_time, artist, title)
);

DROP TABLE IF EXISTS song_counts;

CREATE TABLE IF NOT EXISTS song_counts (
    country TEXT NOT NULL,
    station TEXT NOT NULL,
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    play_count INTEGER NOT NULL,
    PRIMARY KEY (country, station, artist, title)
);

DROP TABLE IF EXISTS collection;

CREATE TABLE IF NOT EXISTS collection (
    catalog_no TEXT NOT NULL,
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    label TEXT NOT NULL,
    format TEXT,
    rating REAL,
    released INTEGER,
    release_id INTEGER,
    collection_folder TEXT,
    date_added TEXT,
    collection_notes TEXT,
    collection_media_condition TEXT,
    collection_sleeve_condition TEXT,
    collection_genre TEXT,
    collection_style TEXT,
    collection_chart_history TEXT,
    collection_label_reprint INTEGER,
    collection_artist_override TEXT
);

DROP TABLE IF EXISTS wantlist;

CREATE TABLE IF NOT EXISTS wantlist (
    catalog_no TEXT NOT NULL,
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    label TEXT NOT NULL,
    format TEXT,
    rating INTEGER,
    released INTEGER,
    release_id TEXT NOT NULL,
    notes TEXT,
    dateadded TEXT
);

DROP TABLE IF EXISTS matches;

CREATE TABLE IF NOT EXISTS matches (
    id INTEGER NOT NULL,
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    country TEXT NOT NULL,
    station TEXT NOT NULL,
    play_count INTEGER NOT NULL,
    match_score REAL,
    matched_source TEXT,
    matched_artist TEXT,
    matched_title TEXT,
    match_note TEXT,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS matched;

CREATE TABLE IF NOT EXISTS matched (
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    matched_source TEXT NOT NULL,
    PRIMARY KEY (artist, title, matched_source)
);

DROP VIEW IF EXISTS v_playlists;

CREATE VIEW IF NOT EXISTS v_playlists AS
SELECT
    p.country,
    p.station,
    p.artist,
    p.title,
    -- Convert play_date to ISO format and combine with play_time
    substr(p.play_date,8,4) || '-' ||
    CASE substr(p.play_date,4,3)
        WHEN 'Jan' THEN '01'
        WHEN 'Feb' THEN '02'
        WHEN 'Mar' THEN '03'
        WHEN 'Apr' THEN '04'
        WHEN 'May' THEN '05'
        WHEN 'Jun' THEN '06'
        WHEN 'Jul' THEN '07'
        WHEN 'Aug' THEN '08'
        WHEN 'Sep' THEN '09'
        WHEN 'Oct' THEN '10'
        WHEN 'Nov' THEN '11'
        WHEN 'Dec' THEN '12'
    END || '-' ||
    substr(p.play_date,1,2) || ' ' || play_time AS play_datetime,
    m.matched_source
FROM playlists p,
     matched m
where p.artist = m.artist 
and   p.title = m.title;

DROP VIEW IF EXISTS v_analysis;

CREATE VIEW IF NOT EXISTS v_analysis AS
SELECT
    sc.country,
    sc.station,
    sc.artist,
    sc.title,
    sc.play_count,
    m.matched_source
FROM song_counts AS sc,
    matched AS m
WHERE
    sc.artist = m.artist
    AND sc.title = m.title
    AND sc.station IN (SELECT station FROM stations WHERE validated = 'Y')
ORDER BY
    sc.artist,
    sc.title;
    
DROP VIEW IF EXISTS v_record_cases;

CREATE VIEW IF NOT EXISTS v_record_cases AS
SELECT
    CASE
        WHEN collection_artist_override = ''
            THEN
                TRIM(
                    CASE
                        WHEN LOWER(artist) LIKE 'the %'
                            THEN
                                CASE
                                    WHEN INSTR(artist, ' (') > 0
                                        THEN
                                            SUBSTR(
                                                artist,
                                                5,
                                                INSTR(artist, ' (') - 5
                                            )
                                    ELSE SUBSTR(artist, 5)
                                END
                        WHEN INSTR(artist, ' (') > 0
                            THEN
                                SUBSTR(artist, 1, INSTR(artist, ' (') - 1)
                        ELSE artist
                    END
                )
        ELSE collection_artist_override
    END AS Artist_Group,
    TRIM(
        CASE
            WHEN LOWER(artist) LIKE 'the %'
                THEN
                    CASE
                        WHEN INSTR(artist, ' (') > 0
                            THEN SUBSTR(artist, 5, INSTR(artist, ' (') - 5)
                        ELSE SUBSTR(artist, 5)
                    END
            WHEN INSTR(artist, ' (') > 0
                THEN SUBSTR(artist, 1, INSTR(artist, ' (') - 1)
            ELSE artist
        END
    ) AS Artist,
    title as Title,
    'https://www.discogs.com/release/' || release_id AS QR_Code,
    CASE
        WHEN released = '0'
            THEN ''
        ELSE released
    END AS Released,
    collection_folder AS Record_Case
FROM collection
WHERE collection_folder LIKE '7"%' OR collection_folder = 'Uncategorized'
ORDER BY UPPER(artist_group), UPPER(artist), title;
