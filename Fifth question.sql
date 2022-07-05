#comparison of GDP growth with growth in prices and salaries over years 2006-2018
WITH comparison AS (
  WITH percentual_changes AS (
    SELECT 
      DISTINCT tkc2.`year` AS year_of_measurement, 
      tkc2.GDP, 
      round((GDP - lag(GDP) OVER (ORDER BY tkc2.`year`)) 
      		/ lag(GDP) OVER (ORDER BY tkc2.`year`) * 100, 2) 
      		AS percentual_GDP_change 
    FROM 
      t_katarina_civanova_project_SQL_secondary_final tkc2 
    WHERE 
      country LIKE 'czech%' 
      AND `year` > 2005 
      AND `year` < 2019 
    order by 
      tkc2.`year`
  ) 
  SELECT 
    DISTINCT year_of_measurement, 
    GDP, 
    percentual_GDP_change, 
    AVG(tkc.avg_price) OVER (PARTITION BY `year` ORDER BY `year`) 
    	AS Average_price, 
    AVG(tkc.avg_salary) OVER (PARTITION BY `year`ORDER BY `year`) 
    	AS Average_salary 
  FROM 
    percentual_changes 
    JOIN t_katarina_civanova_project_sql_primary_final tkc on year_of_measurement = tkc.`year`
) 
SELECT 
  year_of_measurement, 
  GDP, 
  percentual_GDP_change, 
  ROUND((average_price - LAG(average_price) OVER (ORDER BY year_of_measurement)) 
  		/ LAG(average_price) OVER (ORDER BY year_of_measurement) * 100, 2) 
  		AS percentual_price_change, 
  ROUND((average_salary - LAG(average_salary) OVER (ORDER BY year_of_measurement)) 
  		/ LAG(average_salary) OVER (ORDER BY year_of_measurement) * 100, 2) 
  		AS percentual_salary_change 
FROM 
  comparison