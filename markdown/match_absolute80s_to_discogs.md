
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

`match_absolute80s_to_discogs.py` matches tracks from a playlist table
(`absolute80s_song_counts`) against Discogs **collection** and **wantlist**
tables stored in a SQLite database.

The script:

- Performs **exact matches first**
- Falls back to **weighted fuzzy matching** (artist + title)
- Restricts matches to **7\" formats only**
- Produces a single **review-friendly results table**
- Is fully **re-runnable** (results table is dropped and recreated)

The output is designed for **manual inspection and validation**.

---

## INPUT TABLES (REQUIRED)

### absolute80s_song_counts

```
artist TEXT
title TEXT
play_count INTEGER
```

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

```
id INTEGER PRIMARY KEY
artist TEXT
title TEXT
play_count INTEGER
match_score REAL
matched_source TEXT
matched_artist TEXT
matched_title TEXT
match_note TEXT
```

---

## MATCHING RULES

1. Exact match to collection → `match_score = 100`
2. Exact match to wantlist → `match_score = 100`
3. Weighted fuzzy matching

Only **one match source** is assigned per track.

---

## FUZZY MATCHING

### Normalization

- Lowercase
- Remove leading "the "
- Strip punctuation
- Normalize whitespace

### Weighted score

```
(artist_score × artist_weight + title_score × title_weight)
----------------------------------------------------------
           artist_weight + title_weight
```

Scores range from 0–100 and are stored rounded to **1 decimal place**.

---

## OPTIONS

| Option | Description | Default |
|------|------------|---------|
| `--db` | SQLite database path | `database/playlists.db` |
| `--results-table` | Output table name | `matches` |
| `--artist-weight` | Artist weight | `40` |
| `--title-weight` | Title weight | `60` |
| `--min-score` | Minimum fuzzy score | `80` |
| `--strategy` | Matching strategy | `collection_then_wantlist` |
| `--prefer` | Tie breaker | `collection` |

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

## DEPENDENCIES

- Python 3.9+
- pandas
- rapidfuzz
- sqlite3

---

## DESIGN GOALS

- Deterministic
- Review-friendly
- Safe to re-run
- Tunable via CLI
