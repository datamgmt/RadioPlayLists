# Radio Play Lists

## Installation

Setting up the python virtual environment

```
cd RadioPlayLists
python -m venv .
pip install --upgrade pip
pip install requests beautifulsoup4
pip install pandas
pip install rapidfuzz

````

Schedule the user run at 12:00 each day - not change path in this file if required in **crontab.txt**

```
cat crontab.txt| crontab
crontab -l
```

## Running Manually

### Run everything

```
cd RadioPlayLists
./rpl
```


### Run individual steps

Activate the Python VEnv

```
source bin/activate
```

```
python scripts/rpl.py 
```

The data can be loaded into the database - this creates the database and loads all data. If data already exists only new data is loaded

For a complete refresh do this first
```
 rm database/playlists.db data/load_state.json
 ```

```
python scripts/plloader.py
```

This creates/updates SQLite database:
  database/playlists.db

There are two tables:
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

Load the current collection and wantlists from discogs - these need to be downloaded and copied to data/discogs

```
cat sql/create_song_counts.sql | sqlite3 database/playlists.db
```

```
cat sql/create_discogs.sql | sqlite3 database/playlists.db
```

Run the matcha - full docs at [docs/matcha.md](docs/matcha.md)

```
python scripts/matcha.py
```

```
cat sql/create_matched.sql | sqlite3 database/playlists.db
```

Connect to the database and then you can look at the matches

```
sqlite3 database/playlists.db
```

```
select * from matches where country = 'uk' and station = 'absolute80s';
```

To update the matched file run

```
cat sql/update_matched.sql | sqlite3 database/playlists.db
```