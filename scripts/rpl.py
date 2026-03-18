#!/usr/bin/env python3
"""
Scrape OnlineRadioBox playlist pages and write per-station, per-day CSVs.

INPUT:
- data/urls.txt lines look like:
    https://onlineradiobox.com/uk/absolute60s;rock,rock'n'roll,60s

  Format:
    URL;tag1,tag2,tag3
  Tags are ignored by this script.
  Lines starting with # are ignored.

OUTPUT:
- data/<country>/<station>/DD-MON-YYYY.csv
  e.g. data/uk/absolute80s/19-Feb-2026.csv

RULES:
- For each station URL, generate playlist URLs for days 1..6
- Calculate file date as today - N days (Europe/London)
- Skip if output file already exists
- Every written file ALWAYS has a header
"""

import csv
import re
from dataclasses import dataclass
from datetime import datetime, timedelta, date as date_type
from pathlib import Path
from urllib.parse import urlparse
from zoneinfo import ZoneInfo

import requests
from bs4 import BeautifulSoup, NavigableString


BASE_OUT_DIR = Path("data")
URLS_FILE = BASE_OUT_DIR / "stations.csv"

TIME_ONLY_RE = re.compile(r"^\s*(\d{2}:\d{2})\s*$")


@dataclass
class Row:
    date: str
    time: str
    artist: str
    title: str


def london_today() -> date_type:
    return datetime.now(ZoneInfo("Europe/London")).date()


def date_for_day_offset(days_ago: int) -> date_type:
    return london_today() - timedelta(days=days_ago)


def iso_date(d: date_type) -> str:
    return d.isoformat()


def csv_filename_for_date(d: date_type) -> str:
    return d.strftime("%d-%b-%Y") + ".csv"


def normalize_station_base_url(station_url: str) -> str:
    """
    Accepts:
      https://onlineradiobox.com/uk/absolute60s
      https://onlineradiobox.com/uk/absolute60s/anything
    Returns:
      https://onlineradiobox.com/uk/absolute60s
    """
    u = urlparse(station_url.strip())
    parts = [p for p in u.path.split("/") if p][:2]
    return f"{u.scheme}://{u.netloc}/{'/'.join(parts)}"


def build_day_url(base_url: str, days_ago: int) -> str:
    return f"{base_url}/playlist/{days_ago}"


def station_dirs_from_url(base_url: str) -> tuple[str, str]:
    """
    From /uk/absolute80s -> ('uk', 'absolute80s')
    """
    parts = [p for p in urlparse(base_url).path.split("/") if p]
    if len(parts) >= 2:
        return parts[0], parts[1]
    return "unknown", "unknown"


def fetch_html(url: str) -> str:
    r = requests.get(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (compatible; playlist-scraper/1.0)",
            "Accept-Language": "en-GB,en;q=0.9",
        },
        timeout=30,
    )
    r.raise_for_status()
    return r.text


def parse_rows(html: str, date_iso: str) -> list[Row]:
    soup = BeautifulSoup(html, "html.parser")
    rows: list[Row] = []

    for node in soup.find_all(string=TIME_ONLY_RE):
        if not isinstance(node, NavigableString):
            continue

        t = node.strip()
        a = node.find_next("a")
        if not a:
            continue

        track = a.get_text(" ", strip=True).replace("\xa0", " ")
        if " - " in track:
            artist, title = track.split(" - ", 1)
        elif "-" in track:
            artist, title = track.split("-", 1)
        else:
            continue

        rows.append(
            Row(
                date=date_iso,
                time=t,
                artist=artist.strip(),
                title=title.strip(),
            )
        )

    # De-duplication
    seen = set()
    deduped = []
    for r in rows:
        key = (r.time, r.artist, r.title)
        if key not in seen:
            seen.add(key)
            deduped.append(r)

    return deduped


def read_station_urls(path: Path) -> list[str]:
    """
    Reads data/urls.txt lines of the form:
      URL;tag1,tag2,tag3

    Returns only the URL part (before ;)
    Ignores blank lines and lines starting with '#'
    """
    if not path.exists():
        raise FileNotFoundError(f"{path} not found")

    urls: list[str] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue

        url_part = line.split(";")[2].strip()
        if url_part:
            urls.append(url_part)

    return urls


def write_csv(path: Path, rows: list[Row]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["date", "time", "artist", "title"])
        for r in rows:
            w.writerow([r.date, r.time, r.artist, r.title])


def main() -> None:
    station_urls = read_station_urls(URLS_FILE)

    for raw_url in station_urls:
        base_url = normalize_station_base_url(raw_url)
        country, station = station_dirs_from_url(base_url)

        for days_ago in range(1, 7):
            d = date_for_day_offset(days_ago)
            out_path = BASE_OUT_DIR / country / station / csv_filename_for_date(d)

            if out_path.exists():
                print(f"SKIP: {out_path}")
                continue

            try:
                html = fetch_html(build_day_url(base_url, days_ago))
                rows = parse_rows(html, iso_date(d))
                write_csv(out_path, rows)
                print(f"WROTE {len(rows)} rows -> {out_path}")
            except Exception as e:
                print(f"ERROR {base_url} day {days_ago}: {e}")


if __name__ == "__main__":
    main()