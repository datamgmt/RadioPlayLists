#!/usr/bin/env python3
"""
Load scraped playlist CSVs (in ./data) into a SQLite DB (in ./database).

Directory layout expected:
  data/
    urls.txt
    <country>/
      <station>/
        DD-MON-YYYY.csv   (e.g. 22-Feb-2026.csv)

Creates/updates SQLite database:
  db/playlists.db

Tables:
  1) playlists
     - country
     - station
     - playdate   (DD-MON-YYYY, e.g. 22-Feb-2026)
     - playtime   (HH:MM)
     - artist
     - title

  2) stations
     - country
     - station
     - url         (from data/urls.txt)
     - music_tags  (comma-separated string from data/urls.txt; may be empty)

Idempotency:
  - Maintains a state file: data/load_state.json
  - Does NOT reload files already marked loaded in that state file
  - Loads any missing/new CSV files and marks them loaded after successful import

Notes:
  - Uses UNIQUE constraint + INSERT OR IGNORE to avoid duplicate playlist rows.
"""

import csv
import json
import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Tuple
from urllib.parse import urlparse
import re

DATA_DIR = Path("data")
URLS_FILE = DATA_DIR / "urls.txt"
STATE_FILE = DATA_DIR / "load_state.json"

DB_DIR = Path("db")
DB_PATH = DB_DIR / "playlists.db"

FILENAME_DATE_RE = re.compile(r"^\d{2}-[A-Za-z]{3}-\d{4}\.csv$")


@dataclass(frozen=True)
class StationInfo:
    country: str
    station: str
    url: str
    music_tags: str  # raw string after ';' (comma-separated), may be ""


def ensure_dirs() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    DB_DIR.mkdir(parents=True, exist_ok=True)


def load_state() -> Dict[str, bool]:
    if not STATE_FILE.exists():
        return {"loaded_files": {}}
    try:
        obj = json.loads(STATE_FILE.read_text(encoding="utf-8"))
        if not isinstance(obj, dict):
            return {"loaded_files": {}}
        if "loaded_files" not in obj or not isinstance(obj["loaded_files"], dict):
            obj["loaded_files"] = {}
        return obj
    except Exception:
        # If state file is corrupted, start fresh (but do NOT delete it)
        return {"loaded_files": {}}


def save_state(state: Dict[str, bool]) -> None:
    STATE_FILE.write_text(json.dumps(state, indent=2, sort_keys=True), encoding="utf-8")


def connect_db() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("PRAGMA synchronous=NORMAL;")
    conn.execute("PRAGMA foreign_keys=ON;")
    return conn


def create_tables(conn: sqlite3.Connection) -> None:
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS stations (
            country TEXT NOT NULL,
            station TEXT NOT NULL,
            url TEXT NOT NULL,
            music_tags TEXT NOT NULL,
            PRIMARY KEY (country, station)
        );
        """
    )

    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS playlists (
            country TEXT NOT NULL,
            station TEXT NOT NULL,
            playdate TEXT NOT NULL,   -- DD-MON-YYYY
            playtime TEXT NOT NULL,   -- HH:MM
            artist TEXT NOT NULL,
            title TEXT NOT NULL,
            UNIQUE(country, station, playdate, playtime, artist, title)
        );
        """
    )

    conn.execute("CREATE INDEX IF NOT EXISTS idx_playlists_station_date ON playlists(country, station, playdate);")


def parse_country_station_from_station_url(station_url: str) -> Tuple[str, str]:
    """
    From https://onlineradiobox.com/uk/absolute60s -> ('uk', 'absolute60s')
    """
    u = urlparse(station_url.strip())
    parts = [p for p in u.path.split("/") if p]
    if len(parts) >= 2:
        return parts[0], parts[1]
    return "unknown", "unknown"


def read_stations_from_urls_txt() -> Dict[Tuple[str, str], StationInfo]:
    """
    Reads data/urls.txt lines of:
      URL;tag1,tag2,tag3
    Ignores blank lines and lines starting with '#'
    Returns dict keyed by (country, station)
    """
    stations: Dict[Tuple[str, str], StationInfo] = {}

    if not URLS_FILE.exists():
        print(f"WARNING: {URLS_FILE} not found. stations table will not be updated.")
        return stations

    for raw_line in URLS_FILE.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        url_part, tags_part = (line.split(";", 1) + [""])[:2]
        url_part = url_part.strip()
        tags_part = tags_part.strip()

        if not url_part:
            continue

        country, station = parse_country_station_from_station_url(url_part)
        key = (country, station)
        stations[key] = StationInfo(
            country=country,
            station=station,
            url=url_part,
            music_tags=tags_part,
        )

    return stations


def upsert_stations(conn: sqlite3.Connection, stations: Dict[Tuple[str, str], StationInfo]) -> None:
    """
    Keep stations table in sync with urls.txt.
    If a station already exists, update url/music_tags.
    """
    if not stations:
        return

    conn.executemany(
        """
        INSERT INTO stations(country, station, url, music_tags)
        VALUES(?, ?, ?, ?)
        ON CONFLICT(country, station) DO UPDATE SET
            url=excluded.url,
            music_tags=excluded.music_tags
        """,
        [(s.country, s.station, s.url, s.music_tags) for s in stations.values()],
    )


def iter_csv_files(data_dir: Path):
    """
    Yields (country, station, csv_path) for files like:
      data/<country>/<station>/<date>.csv
    """
    for country_dir in data_dir.iterdir():
        if not country_dir.is_dir():
            continue
        country = country_dir.name

        for station_dir in country_dir.iterdir():
            if not station_dir.is_dir():
                continue
            station = station_dir.name

            for csv_path in station_dir.glob("*.csv"):
                if csv_path.name == "urls.txt":
                    continue
                yield country, station, csv_path


def playdate_from_filename(csv_path: Path) -> str:
    """
    Expects filename like 22-Feb-2026.csv -> playdate "22-Feb-2026"
    If filename doesn't match expected format, falls back to stem.
    """
    name = csv_path.name
    if FILENAME_DATE_RE.match(name):
        return csv_path.stem
    return csv_path.stem


def load_one_csv_into_db(
    conn: sqlite3.Connection,
    country: str,
    station: str,
    csv_path: Path,
) -> int:
    """
    Returns number of rows attempted to insert (dedupe handled by INSERT OR IGNORE).
    """
    playdate = playdate_from_filename(csv_path)

    rows_to_insert = []
    with csv_path.open("r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        # expected headers: date,time,artist,title
        for r in reader:
            playtime = (r.get("time") or "").strip()
            artist = (r.get("artist") or "").strip()
            title = (r.get("title") or "").strip()

            if not playtime or not artist or not title:
                continue

            rows_to_insert.append((country, station, playdate, playtime, artist, title))

    if not rows_to_insert:
        return 0

    conn.executemany(
        """
        INSERT OR IGNORE INTO playlists(country, station, playdate, playtime, artist, title)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        rows_to_insert,
    )
    return len(rows_to_insert)


def main() -> None:
    ensure_dirs()

    state = load_state()
    loaded_files: Dict[str, bool] = state.get("loaded_files", {})
    if not isinstance(loaded_files, dict):
        loaded_files = {}
        state["loaded_files"] = loaded_files

    conn = connect_db()
    try:
        create_tables(conn)

        # 1) Update stations table from data/urls.txt
        stations = read_stations_from_urls_txt()
        with conn:
            upsert_stations(conn, stations)

        # 2) Load any missing CSV files (skip those recorded in state)
        newly_loaded = 0
        attempted_rows = 0

        for country, station, csv_path in iter_csv_files(DATA_DIR):
            rel = csv_path.relative_to(DATA_DIR).as_posix()

            if loaded_files.get(rel):
                # Already loaded; skip
                continue

            try:
                with conn:  # transaction per file
                    n = load_one_csv_into_db(conn, country, station, csv_path)

                loaded_files[rel] = True
                newly_loaded += 1
                attempted_rows += n
                print(f"LOADED: {rel}  (rows read: {n})")
            except Exception as e:
                print(f"ERROR loading {rel}: {e}")

        # Save state after processing
        save_state(state)

        print(f"\nDone. Files loaded this run: {newly_loaded}. Rows read this run: {attempted_rows}.")
        print(f"DB: {DB_PATH}")
        print(f"State: {STATE_FILE}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()