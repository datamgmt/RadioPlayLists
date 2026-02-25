.headers on
.mode csv

DROP TABLE IF EXISTS "collection";

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

DROP TABLE IF EXISTS "wantlist";

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

.import --skip 1 data/discogs/collection.csv collection
.import --skip 1 data/discogs/wantlist.csv wantlist
