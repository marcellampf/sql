
-- 1. Sales Growth by Genre
WITH genre_sales AS (
  SELECT
    Year,
    Genre,
    ROUND(SUM(Global_Sales), 2) AS total_sales
  FROM
    `marcellampf-421919.GitProjects.video_game_sales`
  WHERE
    Year IS NOT NULL
  GROUP BY
    Year, Genre
),
genre_growth AS (
  SELECT
    *,
    LAG(total_sales) OVER (PARTITION BY Genre ORDER BY Year) AS prev_year_sales
  FROM
    genre_sales
)
SELECT
  Year,
  Genre,
  total_sales,
  prev_year_sales,
  ROUND(((total_sales - prev_year_sales)/prev_year_sales)*100, 2) AS percent_growth
FROM
  genre_growth
WHERE
  prev_year_sales IS NOT NULL
ORDER BY
  Genre, Year;

-- 2. Outlier Detection by Genre
WITH genre_stats AS (
  SELECT
    Genre,
    AVG(Global_Sales) AS avg_sales,
    STDDEV(Global_Sales) AS std_sales
  FROM
    `marcellampf-421919.GitProjects.video_game_sales`
  GROUP BY Genre
)
SELECT
  vgs.Name,
  vgs.Genre,
  vgs.Global_Sales,
  gs.avg_sales,
  gs.std_sales,
  ROUND((vgs.Global_Sales - gs.avg_sales)/gs.std_sales, 2) AS z_score
FROM
  `marcellampf-421919.GitProjects.video_game_sales` vgs
JOIN
  genre_stats gs
ON
  vgs.Genre = gs.Genre
WHERE
  (vgs.Global_Sales - gs.avg_sales)/gs.std_sales > 2
ORDER BY
  z_score DESC;

-- 3. Game with the same name on the same platform
WITH duplicated_games AS (
  SELECT
    Name,
    COUNT(DISTINCT Platform) AS platform_count
  FROM
    `marcellampf-421919.GitProjects.video_game_sales`
  GROUP BY Name
  HAVING platform_count > 1
)
SELECT
  v.Name,
  v.Platform,
  v.Genre,
  v.Global_Sales,
  v.Year
FROM
  `marcellampf-421919.GitProjects.video_game_sales` v
JOIN
  duplicated_games d
ON
  v.Name = d.Name
ORDER BY
  v.Name, v.Global_Sales DESC;

-- 4. Simple Forecast: Average Sales in the Last 3 Years
WITH last_years AS (
  SELECT DISTINCT Year
  FROM `marcellampf-421919.GitProjects.video_game_sales`
  WHERE Year IS NOT NULL
  ORDER BY Year DESC
  LIMIT 3
),
filtered_data AS (
  SELECT *
  FROM `marcellampf-421919.GitProjects.video_game_sales`
  WHERE Year IN (SELECT Year FROM last_years)
)
SELECT
  Genre,
  ROUND(AVG(Global_Sales), 2) AS avg_sales_last_3_years
FROM
  filtered_data
GROUP BY
  Genre
ORDER BY
  avg_sales_last_3_years DESC;

-- 5. Publisher Market Share by Year**
WITH publisher_sales AS (
  SELECT
    Year,
    Publisher,
    ROUND(SUM(Global_Sales), 2) AS sales
  FROM
    `marcellampf-421919.GitProjects.video_game_sales`
  WHERE
    Year IS NOT NULL
  GROUP BY
    Year, Publisher
),
total_by_year AS (
  SELECT
    Year,
    SUM(sales) AS total_year_sales
  FROM
    publisher_sales
  GROUP BY Year
)
SELECT
  p.Year,
  p.Publisher,
  p.sales,
  t.total_year_sales,
  ROUND((p.sales / t.total_year_sales) * 100, 2) AS market_share
FROM
  publisher_sales p
JOIN
  total_by_year t
ON
  p.Year = t.Year
ORDER BY
  p.Year, market_share DESC;

