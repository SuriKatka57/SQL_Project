# average salary for all available years (2000-2021)
CREATE TABLE IF NOT EXISTS czechia_payroll_average AS 
SELECT 
  DISTINCT cpib.name AS Industry, 
  AVG(cp.value) OVER (
    PARTITION BY cp.payroll_year, cp.industry_branch_code
  ) AS Average_salary, 
  cp.payroll_year 
FROM 
  czechia_payroll cp 
  JOIN czechia_payroll_industry_branch cpib on cp.industry_branch_code = cpib.code 
WHERE 
  cp.value_type_code = 5958 
  AND cp.calculation_code = 100 
ORDER BY 
  industry, 
  payroll_year

# industries with at least one year-to-year decrease in the average salary over the years (2000-2021)
WITH percentual_salary_year_change as (
  SELECT 
    Industry, 
    payroll_year, 
    Average_salary, 
    (
      Average_salary - lag(Average_salary) OVER (
        PARTITION BY Industry 
        ORDER BY 
          industry, 
          payroll_year
      )
    ) / lag(Average_salary) OVER (
      PARTITION BY Industry 
      ORDER BY 
        industry, 
        payroll_year
    ) * 100 AS percentual_year_change 
  FROM 
    czechia_payroll_average
) 
SELECT 
  DISTINCT industry 
FROM 
  percentual_salary_year_change 
WHERE 
  percentual_year_change < 0

# industries with increase in average salary from first to last year (2000-2021)
WITH industries_with_increase as (
  WITH min_max_year_comparison as (
    SELECT 
      Industry, 
      payroll_year, 
      Average_salary 
    FROM 
      czechia_payroll_average cpa 
    WHERE 
      payroll_year = (
        SELECT 
          min(payroll_year) 
        FROM 
          czechia_payroll_average
      ) 
      OR payroll_year = (
        SELECT 
          max(payroll_year) 
        FROM 
          czechia_payroll_average
      )
  ) 
  SELECT 
    Industry, 
    (
      Average_salary - lag(Average_salary) OVER (
        PARTITION BY Industry 
        ORDER BY 
          industry, 
          payroll_year
      )
    ) AS percentual_year_change 
  FROM 
    min_max_year_comparison
) 
SELECT 
  Industry 
FROM 
  industries_with_increase 
WHERE 
  percentual_year_change > 0