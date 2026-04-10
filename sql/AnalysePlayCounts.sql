SELECT
    country,
    station,
    matched_source,
    COUNT(play_count) AS title_count,
    CAST(
        ROUND(
            100.0 * COUNT(play_count)
            / SUM(COUNT(play_count)) OVER(PARTITION BY station),
            1
        ) AS REAL
    ) AS title_count_percentage,
    SUM(play_count) AS play_count,
    CAST(
        ROUND(
            100.0 * SUM(play_count)
            / SUM(SUM(play_count)) OVER(PARTITION BY station),
            1
        ) AS REAL
    ) AS play_count_percentage
FROM v_analysis
GROUP BY
    country,
    station,
    matched_source;
