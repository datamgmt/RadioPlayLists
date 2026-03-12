CREATE TABLE IF NOT EXISTS stations (
    country TEXT NOT NULL,
    station TEXT NOT NULL,
    url TEXT NOT NULL,
    music_tags TEXT NOT NULL,
    PRIMARY KEY (country, station)
);

CREATE TABLE IF NOT EXISTS playlists (
    country TEXT NOT NULL,
    station TEXT NOT NULL,
    playdate TEXT NOT NULL,   -- DD-MON-YYYY
    playtime TEXT NOT NULL,   -- HH:MM
    artist TEXT NOT NULL,
    title TEXT NOT NULL,
    UNIQUE (country, station, playdate, playtime, artist, title)
);

CREATE INDEX IF NOT EXISTS idx_playlists_station_date
ON playlists (country, station, playdate);

CREATE TABLE song_counts (
    country TEXT,
    station TEXT,
    artist TEXT,
    title TEXT,
    play_count
);

CREATE TABLE IF NOT EXISTS "collection" (
    "Catalog#" TEXT,
    "Artist" TEXT,
    "Title" TEXT,
    "Label" TEXT,
    "Format" TEXT,
    "Rating" REAL,
    "Released" INTEGER,
    "release_id" INTEGER,
    "CollectionFolder" TEXT,
    "Date Added" TEXT,
    "Collection Notes" TEXT,
    "Collection Media Condition" TEXT,
    "Collection Sleeve Condition" TEXT,
    "Collection Genre" TEXT,
    "Collection Style" TEXT,
    "Collection Chart History" TEXT,
    "Collection Label Reprint" INTEGER,
    "Collection Artist Override" TEXT
);

CREATE TABLE IF NOT EXISTS "wantlist" (
    "Catalog#" TEXT, 
    "Artist" TEXT,
    "Title" TEXT,
    "Label" TEXT,
    "Format" REAL,
    "Rating" INTEGER,
    "Released" INTEGER,
    "release_id" TEXT,
    "Notes" TEXT,
    "DateAdded" TEXT
);

CREATE TABLE IF NOT EXISTS matches (
    id INTEGER PRIMARY KEY,
    artist TEXT,
    title TEXT,
    country TEXT,
    station TEXT,
    play_count INTEGER,
    match_score REAL,
    matched_source TEXT,
    matched_artist TEXT,
    matched_title TEXT,
    match_note TEXT
);

CREATE TABLE IF NOT EXISTS matched
(
    artist TEXT,
    title TEXT,
    matched_source TEXT
);