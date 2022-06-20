CREATE TABLE IF NOT EXISTS t_Katarina_Civanova_project_SQL_primary_final 
SELECT 
  YEAR(date_from) AS `year`, 
  cpib.name AS industry_name, 
  AVG(cpay.value) AS avg_salary, 
  cpc.name AS food_category, 
  AVG(cp.value) AS avg_price 
FROM 
  czechia_price cp 
  JOIN czechia_payroll cpay ON YEAR(cp.date_to) = cpay.payroll_year 
  JOIN czechia_price_category cpc ON cp.category_code = cpc.code 
  JOIN czechia_payroll_industry_branch cpib ON cpay.industry_branch_code = cpib.code 
WHERE 
  cp.value IS NOT NULL 
  AND cpay.industry_branch_code IS NOT NULL 
  AND cpay.value_type_code = 5958 
  AND cpay.calculation_code = 100 
GROUP BY 
  cpay.payroll_year, 
  cpib.name, 
  cpc.name

#industries with at least one year-to-year decrease in average salary over years (2006-2018)
WITH industries_with_decrease AS (
  WITH percentual_year_change AS (
    SELECT 
      DISTINCT industry_name, 
      `year`, 
      avg_salary 
    FROM 
      t_katarina_civanova_project_sql_primary_final 
    ORDER BY 
      industry_name, 
      `year`
  ) 
--   percentual change in average salaries across industries
  SELECT 
    industry_name, 
    `year`, 
    avg_salary, 
    round(
      (
        avg_salary - lag(avg_salary) OVER (
          PARTITION BY industry_name 
          ORDER BY 
            industry_name, 
            `year`
        )
      ) / lag(avg_salary) OVER (
        PARTITION BY industry_name 
        ORDER BY 
          industry_name, 
          `year`
      ) * 100, 
      2
    ) AS percentual_year_change 
  FROM 
    percentual_year_change
) 
SELECT 
  DISTINCT industry_name 
FROM 
  industries_with_decrease 
WHERE 
  percentual_year_change < 0

#industries with increase in average salary from first to last year (2006-2018)
WITH industries_with_increase as (
  WITH min_max_year_comparison as (
    SELECT 
      industry_name, 
      `year`, 
      avg_salary 
    FROM 
      t_katarina_civanova_project_sql_primary_final 
    WHERE 
      `year` = (
        SELECT 
          min(`year`) 
        FROM 
          t_katarina_civanova_project_sql_primary_final
      ) 
      OR `year` = (
        SELECT 
          max(`year`) 
        FROM 
          t_katarina_civanova_project_sql_primary_final
      )
  ) 
  SELECT 
    industry_name, 
    (
      avg_salary - lag(avg_salary) OVER (
        PARTITION BY industry_name 
        ORDER BY 
          industry_name, 
          `year`
      )
    ) AS percentual_year_change 
  FROM 
    min_max_year_comparison
) 
SELECT 
  industry_name 
FROM 
  industries_with_increase 
WHERE 
  percentual_year_change > 0