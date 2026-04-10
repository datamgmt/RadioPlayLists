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
    country,
    station,
    artist,
    title,
    -- Convert play_date to ISO format and combine with play_time
    substr(play_date,8,4) || '-' ||
    CASE substr(play_date,4,3)
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
    substr(play_date,1,2) || ' ' || play_time AS play_datetime
FROM playlists;

DROP VIEW IF EXISTS v_80s_analysis;

CREATE VIEW IF NOT EXISTS v_80s_analysis AS
SELECT
    sc.artist,
    sc.title,
    sc.play_count,
    m.matched_source
FROM song_counts AS sc,
    matched AS m
WHERE
    sc.artist = m.artist
    AND sc.title = m.title
    AND sc.country = 'uk'
    AND sc.station = 'absolute80s'
ORDER BY
    sc.artist,
    sc.title;