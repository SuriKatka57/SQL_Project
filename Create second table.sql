CREATE TABLE IF NOT EXISTS t_katarina_civanova_project_SQL_secondary_final 
SELECT 
  c.region_in_world, 
  c.country, 
  e.`year`, 
  e.GDP 
FROM 
  economies AS e 
  JOIN countries AS c ON e.country = c.country 
WHERE 
  lower(c.region_in_world) LIKE '%europe%' 
  AND e.gdp IS NOT NULL 
ORDER BY 
  country, 
  `year`
