SELECT
    country,
    station,
    matched_source,

    printf('%11d', COUNT(play_count)) AS title_count,

    printf('%22.2f',
        100.0 * COUNT(play_count)
        / SUM(COUNT(play_count)) OVER(PARTITION BY station)
    ) AS title_count_percentage,

    printf('%10d', SUM(play_count)) AS play_count,

    printf('%21.2f',
        100.0 * SUM(play_count)
        / SUM(SUM(play_count)) OVER(PARTITION BY station)
    ) AS play_count_percentage
FROM v_analysis
GROUP BY
    country,
    station,
    matched_source;
    

SELECT
    date(v.play_datetime) AS date,

    printf('%10d', sum(m.matched_source = 'collection')) AS collection,
    printf('%8d', sum(m.matched_source = 'wantlist')) AS wantlist,
    printf('%8d', sum(m.matched_source = 'no vinyl')) AS no_vinyl,
    printf('%5d', sum(1)) AS total,

    printf('%14.2f',
        100.0 * sum(m.matched_source = 'collection') / sum(1)
    ) AS pct_collection,

    printf('%12.2f',
        100.0 * sum(m.matched_source = 'wantlist') / sum(1)
    ) AS pct_wantlist,

    printf('%12.2f',
        100.0 * sum(m.matched_source = 'no vinyl') / sum(1)
    ) AS pct_no_vinyl
FROM v_playlists AS v
JOIN matched AS m
    ON v.artist = m.artist
   AND v.title = m.title
WHERE
    v.country = 'uk'
    AND v.station = 'absolute80s'
    AND v.play_datetime >= date('now', '-7 days')
GROUP BY
    date(v.play_datetime)
ORDER BY
    date(v.play_datetime);
    
WITH daily AS (
    SELECT
        date(v.play_datetime) AS date,
        printf('%14.2f',
            100.0 * sum(m.matched_source = 'collection') / sum(1)
        ) AS pct_collection
    FROM v_playlists AS v
    JOIN matched AS m
        ON v.artist = m.artist
       AND v.title = m.title
    WHERE
        v.country = 'uk'
        AND v.station = 'absolute80s'
    GROUP BY date(v.play_datetime)
)
SELECT
    date,
    printf('%14.2f', pct_collection) AS pct_collection
FROM daily
WHERE pct_collection = (SELECT MAX(pct_collection) FROM daily)
ORDER BY date;    
