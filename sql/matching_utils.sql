
SELECT *
FROM matches m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched d
    WHERE d.country = m.country
      AND d.station = m.station
      AND d.artist  = m.artist
      AND d.title   = m.title
);

SELECT id, artist, matched_artist, title, matched_title, matched_source, match_score
FROM matches m
WHERE NOT EXISTS (
    SELECT 1
    FROM matched d
    WHERE d.country = m.country
      AND d.station = m.station
      AND d.artist  = m.artist
      AND d.title   = m.title
) and station = 'absolute70s' and match_score is null
order by id;

update matches set matched_source = 'wantlist' where station = 'absolute80s' and id in (546,548,712,722,723,905,907,910,911,917);

update matches set matched_source = 'collection' where station = 'absolute80s' and matched_source is null and id < 100;