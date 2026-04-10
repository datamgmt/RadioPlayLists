SELECT
    matched_source,
    count(play_count) AS title_count,
    sum(play_count) AS play_count
FROM v_80s_analysis
GROUP BY matched_source;
