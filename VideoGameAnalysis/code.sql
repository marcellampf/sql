SELECT
  Platform,
  ROUND(SUM(Global_Sales), 2) AS Total_Global_Sales_M
FROM
  `myProject.GitProjects.video_game_sales`
GROUP BY
  Platform
ORDER BY
  Total_Global_Sales_M DESC;
---------------------------------------------------------------
SELECT
  Name,
  Platform,
  Year,
  Genre,
  Publisher,
  ROUND(Global_Sales, 2) AS Sales_Millions
FROM
  `myProject.GitProjects.video_game_sales`
ORDER BY
  Global_Sales DESC
LIMIT 10;
---------------------------------------------------------------
SELECT
  Year,
  Genre,
  ROUND(SUM(Global_Sales), 2) AS Total_Sales
FROM
  `myProject.GitProjects.video_game_sales`
WHERE
  Year IS NOT NULL
GROUP BY
  Year, Genre
ORDER BY
  Year ASC, Total_Sales DESC;
---------------------------------------------------------------
  SELECT
  Platform,
  ROUND(SUM(NA_Sales), 2) AS North_America,
  ROUND(SUM(EU_Sales), 2) AS Europe,
  ROUND(SUM(JP_Sales), 2) AS Japan,
  ROUND(SUM(Other_Sales), 2) AS Other_Regions
FROM
  `myProject.GitProjects.video_game_sales`
GROUP BY
  Platform
ORDER BY
  North_America DESC;
--------------------------------------------------------------
SELECT
  Genre,
  Name,
  Platform,
  Global_Sales,
  RANK() OVER (PARTITION BY Genre ORDER BY Global_Sales DESC) AS Genre_Rank
FROM
  `myProject.GitProjects.video_game_sales`
QUALIFY Genre_Rank <= 3
ORDER BY
  Genre, Genre_Rank;


