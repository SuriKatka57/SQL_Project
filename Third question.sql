#slowest increase in price of food category
WITH categories_with_increase AS (
  WITH average_percentual_year_change AS (
-- percentual change in prices over years
  	SELECT 
      food_category, 
      `year`, 
      avg_price, 
      ROUND(
        (
          avg_price - LAG(avg_price) OVER (
            PARTITION BY food_category 
            ORDER BY 
              food_category, 
              `year`
          )
        ) / LAG(avg_price) OVER (
          PARTITION BY food_category 
          ORDER BY 
            food_category, 
            `year`
        ) * 100, 
        2
      ) AS percentual_year_change 
    FROM 
      t_katarina_civanova_project_sql_primary_final tkc 
    GROUP BY 
      food_category, 
      `year`
  ) 
-- average percentual change of food categories
  SELECT 
    DISTINCT food_category, 
    AVG(percentual_year_change) OVER (PARTITION BY food_category) AS average_change 
  FROM 
    average_percentual_year_change
) 
-- food category with smallest average change in price
SELECT 
  food_category, 
  average_change 
FROM 
  categories_with_increase 
WHERE 
  average_change > 0 
ORDER BY 
  average_change
LIMIT 
  1