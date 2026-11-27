-- Q1: Overall summary of the data
SELECT COUNT(*) AS records, COUNT(DISTINCT title) AS distinct_titles,
       ROUND(SUM(revenue_musd)/1000,1) AS total_revenue_bn,
       ROUND(AVG(revenue_musd),0) AS avg_revenue_musd,
       ROUND(AVG(players_m),1) AS avg_players_m,
       ROUND(AVG(peak_ccu_m),1) AS avg_peak_ccu_m,
       ROUND(AVG(metacritic),1) AS avg_metacritic
FROM games;

-- Q2: Genre comparison
SELECT genre, COUNT(*) AS games, ROUND(AVG(revenue_musd),0) AS avg_revenue_musd,
       ROUND(AVG(players_m),1) AS avg_players_m,
       ROUND(AVG(peak_ccu_m),1) AS avg_peak_ccu_m,
       ROUND(AVG(peak_ccu_m*1.0/players_m),3) AS peak_to_player_ratio
FROM games GROUP BY genre ORDER BY avg_revenue_musd DESC;

-- Q3: Platforms with more than 150 games
SELECT platform, COUNT(*) AS games, ROUND(AVG(metacritic),1) AS avg_metacritic,
       ROUND(AVG(revenue_musd),0) AS avg_revenue_musd
FROM games GROUP BY platform HAVING COUNT(*) > 150 ORDER BY games DESC;

-- Q4: Revenue by developer country (join)
SELECT d.hq_country, COUNT(*) AS games, COUNT(DISTINCT g.developer) AS developers,
       ROUND(SUM(g.revenue_musd)/1000,1) AS total_revenue_bn,
       ROUND(AVG(g.metacritic),1) AS avg_metacritic
FROM games g JOIN dim_developer d ON g.developer = d.developer
GROUP BY d.hq_country ORDER BY total_revenue_bn DESC;

-- Q5: Platform type summary (join)
SELECT p.platform_type, COUNT(*) AS games,
       ROUND(AVG(g.players_m),1) AS avg_players_m,
       ROUND(AVG(g.peak_ccu_m),1) AS avg_peak_ccu_m,
       ROUND(100.0*SUM(CASE WHEN g.esports='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS pct_esports
FROM games g JOIN dim_platform p ON g.platform = p.platform
GROUP BY p.platform_type ORDER BY avg_peak_ccu_m DESC;

-- Q6: Esports vs non-esports games
SELECT esports, COUNT(*) AS games, ROUND(AVG(revenue_musd),0) AS avg_revenue_musd,
       ROUND(AVG(players_m),1) AS avg_players_m,
       ROUND(AVG(peak_ccu_m*1.0/players_m),3) AS peak_to_player_ratio
FROM games GROUP BY esports;

-- Q7: Games grouped by Metacritic score band
SELECT CASE WHEN metacritic >= 85 THEN '1. Acclaimed (85+)'
            WHEN metacritic >= 70 THEN '2. Good (70-84)'
            WHEN metacritic >= 60 THEN '3. Mixed (60-69)'
            ELSE '4. Weak (<60)' END AS quality_band,
       COUNT(*) AS games, ROUND(AVG(players_m),1) AS avg_players_m,
       ROUND(AVG(peak_ccu_m),1) AS avg_peak_ccu_m,
       ROUND(AVG(peak_ccu_m*1.0/players_m),3) AS peak_to_player_ratio,
       ROUND(AVG(revenue_musd),0) AS avg_revenue_musd
FROM games GROUP BY quality_band ORDER BY quality_band;

-- Q8: Top 3 revenue games in each genre
SELECT genre, title, platform, release_year, revenue_musd, rn FROM (
    SELECT genre, title, platform, release_year, revenue_musd,
           ROW_NUMBER() OVER (PARTITION BY genre ORDER BY revenue_musd DESC) AS rn
    FROM games) WHERE rn <= 3 ORDER BY genre, rn;

-- Q9: Developers earning above the overall average
WITH dev AS (
    SELECT developer, COUNT(*) AS games, AVG(revenue_musd) AS avg_rev, AVG(metacritic) AS avg_meta
    FROM games GROUP BY developer)
SELECT developer, games, ROUND(avg_rev,0) AS avg_revenue_musd, ROUND(avg_meta,1) AS avg_metacritic
FROM dev WHERE avg_rev > (SELECT AVG(revenue_musd) FROM games)
ORDER BY avg_rev DESC;

-- Q10: Trend across 5-year release blocks
SELECT (release_year/5)*5 AS five_year_block, COUNT(*) AS games,
       ROUND(AVG(revenue_musd),0) AS avg_revenue_musd,
       ROUND(AVG(peak_ccu_m),1) AS avg_peak_ccu_m,
       ROUND(AVG(metacritic),1) AS avg_metacritic
FROM games GROUP BY five_year_block ORDER BY five_year_block;

-- Q11: Trending status split by esports
SELECT trending, COUNT(*) AS games,
       SUM(CASE WHEN esports='Yes' THEN 1 ELSE 0 END) AS esports_games,
       SUM(CASE WHEN esports='No' THEN 1 ELSE 0 END) AS non_esports_games,
       ROUND(AVG(revenue_musd),0) AS avg_revenue_musd
FROM games GROUP BY trending ORDER BY games DESC;

-- Q12: Genre and platform type with the highest average peak players
SELECT g.genre, p.platform_type, COUNT(*) AS games, ROUND(AVG(g.peak_ccu_m),1) AS avg_peak_ccu_m
FROM games g JOIN dim_platform p ON g.platform = p.platform
GROUP BY g.genre, p.platform_type HAVING COUNT(*) >= 15
ORDER BY avg_peak_ccu_m DESC LIMIT 8;
