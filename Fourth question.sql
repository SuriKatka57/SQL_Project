#comparison of increase in prices vs salaries
WITH comparison AS (
  WITH percentual_change AS (
-- average salary and price by years
  	SELECT 
      DISTINCT `year`, 
      AVG(tkc.avg_price) OVER (
        PARTITION BY tkc.`year` 
        ORDER BY 
          `year`
      ) AS Average_price, 
      AVG(tkc.avg_salary) OVER (
        PARTITION BY tkc.`year` 
        ORDER BY 
          `year`
      ) as Average_salary 
    FROM 
      t_katarina_civanova_project_sql_primary_final tkc
  ) 
--   percentual change over years in price and salary
  SELECT 
    `year`, 
    ROUND((Average_salary - lag(Average_salary) OVER (ORDER BY `year`)) 
    		/ lag(Average_salary) OVER (ORDER BY `year`) 
    		* 100, 2) 
    		as percentual_salary_change, 
    ROUND((Average_price - lag(Average_price) OVER (ORDER BY `year`)) 
            / lag(Average_price) OVER (ORDER BY `year`) 
            * 100, 2) as percentual_price_change 
  FROM 
    percentual_change
) 
-- difference in price vs salary increase
SELECT 
  `year`, 
  percentual_salary_change, 
  percentual_price_change, 
  CASE WHEN percentual_price_change < 0 THEN percentual_price_change + percentual_salary_change 
  	   WHEN percentual_price_change > 0 THEN percentual_price_change - percentual_salary_change 
  END AS difference
FROM 
  comparison
ORDER BY 
  difference DESC