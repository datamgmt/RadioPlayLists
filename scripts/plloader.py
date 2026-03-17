#!/usr/bin/env python3

import csv
import json
import sqlite3
from pathlib import Path
from typing import Dict

DATA_DIR = Path("data")
STATE_FILE = DATA_DIR / "load_state.json"

DB_PATH = Path("db/playlists.db")


def load_state() -> Dict[str, bool]:
    if not STATE_FILE.exists():
        return {"loaded_files": {}}

    try:
        return json.loads(STATE_FILE.read_text())
    except Exception:
        return {"loaded_files": {}}


def save_state(state):
    STATE_FILE.write_text(json.dumps(state, indent=2))


def connect_db():
    return sqlite3.connect(DB_PATH)


def iter_csv_files():
    """
    Yields (country, station, csv_path)
    from data/<country>/<station>/<date>.csv
    """
    for country_dir in DATA_DIR.iterdir():
        if not country_dir.is_dir():
            continue

        for station_dir in country_dir.iterdir():
            if not station_dir.is_dir():
                continue

            for csv_path in station_dir.glob("*.csv"):
                yield country_dir.name, station_dir.name, csv_path


def load_csv(conn, country, station, csv_path):
    play_date = csv_path.stem

    rows = []

    with csv_path.open(encoding="utf-8") as f:
        reader = csv.DictReader(f)

        for r in reader:
            play_time = (r.get("time") or "").strip()
            artist = (r.get("artist") or "").strip()
            title = (r.get("title") or "").strip()

            if play_time and artist and title:
                rows.append(
                    (country, station, play_date, play_time, artist, title)
                )

    if not rows:
        return 0

    conn.executemany(
        """
        INSERT OR IGNORE INTO playlists
        (country, station, play_date, play_time, artist, title)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        rows,
    )

    return len(rows)


def main():
    state = load_state()
    loaded = state.setdefault("loaded_files", {})

    conn = connect_db()

    files_loaded = 0
    rows_loaded = 0

    for country, station, csv_path in iter_csv_files():

        rel = csv_path.relative_to(DATA_DIR).as_posix()

        if loaded.get(rel):
            continue

        try:
            with conn:
                n = load_csv(conn, country, station, csv_path)

            loaded[rel] = True
            files_loaded += 1
            rows_loaded += n

            print(f"Loaded {rel} ({n} rows)")

        except Exception as e:
            print(f"ERROR {rel}: {e}")

    save_state(state)

    print(f"\nDone. Files: {files_loaded}  Rows: {rows_loaded}")

    conn.close()


if __name__ == "__main__":
    main() 