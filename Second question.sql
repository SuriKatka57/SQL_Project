#affordability of bread and milk in first and last year
WITH bread_and_milk_affordability AS (
  SELECT 
-- average salary across years
    DISTINCT tkc.food_category, 
    tkc.`year`, 
    tkc.avg_price, 
    tkc.category_code, 
    AVG(tkc.avg_salary) OVER (
      PARTITION BY tkc.`year` 
      ORDER BY 
        `year`
    ) as Average_salary 
  FROM 
    t_katarina_civanova_project_sql_primary_final tkc 
--  selection of bread and milk category and first and last available year
   WHERE 
    category_code in (111301, 114201) 
    and (
      (
        `year` = (
          SELECT 
            min(`year`) 
          FROM 
            t_katarina_civanova_project_sql_primary_final
        )
      ) 
      OR (
        `year` = (
          SELECT 
            max(`year`) 
          FROM 
            t_katarina_civanova_project_sql_primary_final
        )
      )
    )
) 
-- counting affordability and adding units
SELECT 
  `year`, 
  food_category, 
  CONCAT(
    ROUND (average_salary / avg_price, 2), 
    ' ', 
    cpc.price_unit
  ) as affordability 
FROM 
  bread_and_milk_affordability 
  JOIN czechia_price_category cpc ON bread_and_milk_affordability.category_code = cpc.code 
ORDER BY 
  `year`
