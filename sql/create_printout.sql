.mode csv
.echo off
.output data/printout.csv

SELECT
    -- Process artist names
    CASE 
        WHEN m.artist LIKE 'The %' THEN 
            REPLACE(SUBSTR(m.artist, 5), ' and ', ' & ')
        ELSE
            REPLACE(m.artist, ' and ', ' & ')
    END AS artist,
    m.title,
    COALESCE(SUM(sc.play_count), 0) AS play_count
FROM (
    SELECT DISTINCT artist, title
    FROM matched
    WHERE matched_source = 'wantlist'
) m
LEFT JOIN song_counts sc
    ON sc.artist = m.artist
   AND sc.title  = m.title
GROUP BY 
    CASE 
        WHEN m.artist LIKE 'The %' THEN 
            REPLACE(SUBSTR(m.artist, 5), ' and ', ' & ')
        ELSE
            REPLACE(m.artist, ' and ', ' & ')
    END,
    m.title;
    
.output
.echo on
.mode column
