#!/usr/bin/env python3
"""
Match song_counts to Discogs collection/wantlist in SQLite using weighted fuzzy matching.

Key rules:
- match_score rounded to 1 decimal place
- Collection AND wantlist restricted to Format containing 7"
- Exact match → match_score = 100.0
- Fuzzy match otherwise (weighted artist/title)
- matched_source indicates collection or wantlist
- Results written to table: matches
"""

import argparse
import sqlite3
import re
import pandas as pd
from rapidfuzz import fuzz, process

DB_DEFAULT = "db/playlists.db"
RESULTS_TABLE_DEFAULT = "matches"

# ---------- Normalization helpers ----------
_THE_PREFIX = re.compile(r"^\s*the\s+", re.IGNORECASE)
_NON_ALNUM = re.compile(r"[^a-z0-9]+")

def norm_text(s: str) -> str:
    if s is None:
        return ""
    s = str(s).strip().lower()
    s = _THE_PREFIX.sub("", s)
    s = _NON_ALNUM.sub(" ", s)
    return " ".join(s.split())

DELIM = "\u241F"

def pack_key(artist: str, title: str) -> str:
    return f"{norm_text(artist)}{DELIM}{norm_text(title)}"

def unpack_key(packed: str):
    return packed.split(DELIM, 1)

def make_weighted_scorer(artist_weight: float, title_weight: float):
    aw, tw = float(artist_weight), float(title_weight)
    denom = aw + tw or 1.0

    def scorer(q, c, **_):
        qa, qt = unpack_key(q)
        ca, ct = unpack_key(c)
        return (
            fuzz.token_sort_ratio(qa, ca) * aw +
            fuzz.token_sort_ratio(qt, ct) * tw
        ) / denom

    return scorer

def round1(x):
    return None if x is None else round(float(x), 1)

def best_match(query, candidates, scorer, min_score):
    if not candidates:
        return None, 0.0
    hit = process.extractOne(query, candidates, scorer=scorer, score_cutoff=min_score)
    return (hit[0], float(hit[1])) if hit else (None, 0.0)

def ensure_results_table(conn, table):
    cur = conn.cursor()
    cur.execute(f"DROP TABLE IF EXISTS {table}")
    cur.execute(f"""
        CREATE TABLE {table} (
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
        )
    """)
    conn.commit()

def insert_results(conn, table, df):
    cols = [
        "artist", "title", "country", "station", "play_count",
        "match_score", "matched_source",
        "matched_artist", "matched_title",
        "match_note"
    ]
    sql = f"INSERT INTO {table} ({','.join(cols)}) VALUES ({','.join(['?']*len(cols))})"
    conn.executemany(sql, df[cols].itertuples(index=False, name=None))
    conn.commit()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--db", default=DB_DEFAULT)
    parser.add_argument("--results-table", default=RESULTS_TABLE_DEFAULT)
    parser.add_argument("--artist-weight", type=float, default=40.0)
    parser.add_argument("--title-weight", type=float, default=60.0)
    parser.add_argument("--min-score", type=float, default=80.0)
    parser.add_argument("--strategy", choices=["collection_then_wantlist", "best_of_both"],
                        default="collection_then_wantlist")
    parser.add_argument("--prefer", choices=["collection", "wantlist"], default="collection")
    args = parser.parse_args()

    scorer = make_weighted_scorer(args.artist_weight, args.title_weight)
    conn = sqlite3.connect(args.db)

    # 🔹 UPDATED SOURCE TABLE
    songs = pd.read_sql(
        "SELECT artist, title, country, station, play_count FROM song_counts",
        conn
    )

    collection = pd.read_sql("""
        SELECT * FROM collection
        WHERE COALESCE(Format,'') LIKE '%7"%'
    """, conn)

    wantlist = pd.read_sql("""
        SELECT * FROM wantlist
        WHERE COALESCE(Format,'') LIKE '%7"%'
    """, conn)

    songs["k"] = songs.apply(lambda r: pack_key(r.artist, r.title), axis=1)
    collection["k"] = collection.apply(lambda r: pack_key(r.Artist, r.Title), axis=1)
    wantlist["k"] = wantlist.apply(lambda r: pack_key(r.Artist, r.Title), axis=1)

    c_by = collection.drop_duplicates("k").set_index("k")
    w_by = wantlist.drop_duplicates("k").set_index("k")

    c_keys = collection["k"].tolist()
    w_keys = wantlist["k"].tolist()

    rows = []

    for _, s in songs.iterrows():
        row = dict(
            artist=s.artist,
            title=s.title,
            country=s.country,
            station=s.station,
            play_count=int(s.play_count),
            match_score=None,
            matched_source=None,
            matched_artist=None,
            matched_title=None,
            match_note=None,
        )

        if s.k in c_by.index:
            m = c_by.loc[s.k]
            row.update(
                match_score=100.0,
                matched_source="collection",
                matched_artist=m.Artist,
                matched_title=m.Title,
                match_note='exact match to collection (7")'
            )

        elif s.k in w_by.index:
            m = w_by.loc[s.k]
            row.update(
                match_score=100.0,
                matched_source="wantlist",
                matched_artist=m.Artist,
                matched_title=m.Title,
                match_note='exact match to wantlist (7")'
            )

        else:
            ck, cs = best_match(s.k, c_keys, scorer, args.min_score)
            wk, ws = best_match(s.k, w_keys, scorer, args.min_score)

            if args.strategy == "collection_then_wantlist":
                if ck:
                    m = c_by.loc[ck]
                    row.update(
                        match_score=round1(cs),
                        matched_source="collection",
                        matched_artist=m.Artist,
                        matched_title=m.Title,
                        match_note="best fuzzy match to collection"
                    )
                elif wk:
                    m = w_by.loc[wk]
                    row.update(
                        match_score=round1(ws),
                        matched_source="wantlist",
                        matched_artist=m.Artist,
                        matched_title=m.Title,
                        match_note="best fuzzy match to wantlist"
                    )
                else:
                    row["match_note"] = "no match"

            else:
                if cs > ws or (cs == ws and args.prefer == "collection"):
                    if ck:
                        m = c_by.loc[ck]
                        row.update(
                            match_score=round1(cs),
                            matched_source="collection",
                            matched_artist=m.Artist,
                            matched_title=m.Title,
                            match_note="best fuzzy match (collection)"
                        )
                elif wk:
                    m = w_by.loc[wk]
                    row.update(
                        match_score=round1(ws),
                        matched_source="wantlist",
                        matched_artist=m.Artist,
                        matched_title=m.Title,
                        match_note="best fuzzy match (wantlist)"
                    )

        rows.append(row)

    results = pd.DataFrame(rows)

    ensure_results_table(conn, args.results_table)
    insert_results(conn, args.results_table, results)

    print(f"Wrote {len(results)} rows to table '{args.results_table}' in {args.db}")
    conn.close()

if __name__ == "__main__":
    main()