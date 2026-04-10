SELECT
    country,
    station,
    matched_source,
    count(play_count) AS title_count,
    sum(play_count) AS play_count
FROM v_analysis
GROUP BY 
    country,
    station,
    matched_source;
