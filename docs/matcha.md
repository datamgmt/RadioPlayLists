# match_absolute80s_to_discogs

Match playlist tracks against Discogs **collection** and **wantlist** data using weighted fuzzy matching, and store the results in SQLite for review.

---

## NAME

**match_absolute80s_to_discogs** — weighted fuzzy matcher for playlist tracks vs Discogs exports

---

## SYNOPSIS

```bash
python match_absolute80s_to_discogs.py [options]
```

---

## DESCRIPTION

`match_absolute80s_to_discogs.py` matches tracks from a playlist-style table
(`song_counts`) against Discogs **collection** and **wantlist**
tables stored in a SQLite database.

The script:

- Performs **exact matches first**
- Falls back to **weighted fuzzy matching** (artist + title)
- Restricts matches to **7\" formats only**
- Preserves **country** and **station** metadata
- Produces a single **review-friendly results table**
- Is fully **re-runnable** (results table is dropped and recreated)

The output is designed for **manual inspection and validation**.

---

## INPUT TABLES (REQUIRED)

### song_counts

```sql
artist TEXT
title TEXT
country TEXT
station TEXT
play_count INTEGER
```

Each row represents airplay for a specific song on a specific station in a specific country.

### collection

Discogs collection export.  
Only rows where `Format` contains `7"` are considered.

### wantlist

Discogs wantlist export.  
Only rows where `Format` contains `7"` are considered.

---

## OUTPUT TABLE

### matches

The script drops and recreates this table on every run.

```sql
CREATE TABLE matches (
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
```

---

## MATCHING RULES

Matching is performed in the following order:

1. **Exact match to collection**  
   → `match_score = 100`, `matched_source = collection`

2. **Exact match to wantlist**  
   → `match_score = 100`, `matched_source = wantlist`

3. **Weighted fuzzy matching**
   - Artist and title are normalized
   - A weighted score is calculated
   - Strategy determines whether collection or wantlist is tried first

Only **one match source** is assigned per track.

---

## FUZZY MATCHING DETAILS

### Normalization

Before matching:

- Lowercased
- Leading `"the "` removed
- Punctuation stripped
- Whitespace normalized

### Scoring

```text
(artist_score × artist_weight + title_score × title_weight)
----------------------------------------------------------
           artist_weight + title_weight
```

- Uses RapidFuzz `token_sort_ratio`
- Scores range from 0–100
- Stored rounded to **1 decimal place**

---

## OPTIONS

| Option | Description | Default |
|------|------------|---------|
| `--db` | SQLite database path | `database/playlists.db` |
| `--results-table` | Output table name | `matches` |
| `--artist-weight` | Artist similarity weight | `40` |
| `--title-weight` | Title similarity weight | `60` |
| `--min-score` | Minimum fuzzy score | `80` |
| `--strategy` | Matching strategy | `collection_then_wantlist` |
| `--prefer` | Tie breaker (best_of_both only) | `collection` |

---

## EXAMPLES

Run with defaults:

```bash
python match_absolute80s_to_discogs.py
```

Lower fuzzy threshold:

```bash
python match_absolute80s_to_discogs.py --min-score 75
```

Favor title similarity:

```bash
python match_absolute80s_to_discogs.py --artist-weight 30 --title-weight 70
```

---

## DESIGN GOALS

- Deterministic results
- Review-friendly output
- Safe re-runs
- Tunable via CLI
- Preserves broadcast context (country / station)

---

## DEPENDENCIES

- Python 3.9+
- pandas
- rapidfuzz
- sqlite3 (standard library)

---

## EXIT STATUS

- `0` — success
- non-zero — error (missing tables, invalid DB path, etc.)
