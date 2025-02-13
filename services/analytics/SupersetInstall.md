
# DuckDb setup

For trans.duckdb in the same folder as the execution you can add in this connection string:
duckdb:///./trans.db

Add this to the advanced
```json
{
    "connect_args": {
        "read_only": true
    }
}
```


# Export superset data

TODO create a dashboard for DuckDB, the /app/data/transformations/companies_registry_analysis.duckdb, ensure filter works on dashboard, export the dashboard and on a totally new build import it and see it works (set the dashboard to refresh the data regularly!!!)


# Use these as ways to get insights

## Overall Risk Distribution Chart

```sql
SELECT 
    CASE 
        WHEN composite_risk_score >= 7 THEN 'High Risk'
        WHEN composite_risk_score >= 4 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_category,
    COUNT(*) as company_count
FROM fact_risk_assessments
GROUP BY risk_category
ORDER BY risk_category;
```

This visualization should be implemented as a pie chart or donut chart to show the proportion of companies in each risk category.

## High-Risk Location Analysis

```sql
SELECT 
    dim_location.city,
    dim_location.country_code,
    COUNT(*) as company_count
FROM dim_location
INNER JOIN dim_company 
    ON dim_location.city = dim_company.city 
    AND dim_location.country_code = dim_company.country_code
WHERE dim_location.risk_level = 'High'
GROUP BY 
    dim_location.city,
    dim_location.country_code
ORDER BY company_count DESC
LIMIT 10
```
{
    "engine_params": {
        "connect_args": {
            "read_only": true
        }
    }
}
This should be visualized as a bar chart showing the concentration of companies in high-risk locations.

## PEP Director Monitoring

```sql
SELECT 
    c.company_name,
    COUNT(d.director_id) as pep_director_count
FROM dim_company c
JOIN dim_director d ON c.company_id = d.company_id
WHERE d.is_pep = 1
GROUP BY c.company_name
HAVING pep_director_count > 0
ORDER BY pep_director_count DESC;
```

## Company Composite Risk Score Distribution

```sql
SELECT
    c.company_name,
    r.composite_risk_score
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
ORDER BY r.composite_risk_score DESC;

SELECT
    c.company_name,
    ROUND(r.composite_risk_score, 2) as composite_risk_score
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
ORDER BY r.composite_risk_score DESC;
```

We can show a bar chart that displays each company’s composite risk score. This visualization makes it easy to compare risk levels across companies.

## Average Composite Risk by City (Geographical Map)

By grouping companies by their registered city and country, we can create a map or bubble chart that shows the average composite risk score per location. This helps in identifying geographic areas with higher risk.

Map or Bubble Chart (with latitude/longitude conversion if needed)

```sql
SELECT
    c.city,
    c.country_code,
    AVG(r.composite_risk_score) AS avg_composite_risk
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
GROUP BY c.city, c.country_code;

SELECT
    c.city,
    c.country_code,
    ROUND(AVG(r.composite_risk_score), 2) AS avg_composite_risk
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
GROUP BY c.city, c.country_code;
```

## Risk Trend by Incorporation Year

We can analyze how the composite risk score varies with the incorporation year of companies. A time-series or bar chart can display the average composite risk per year, potentially revealing trends over time.

Time-series Line Chart or Bar Chart


```sql
SELECT
    EXTRACT(YEAR FROM c.incorporation_date) AS incorporation_year,
    AVG(r.composite_risk_score) AS avg_composite_risk
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
GROUP BY incorporation_year
ORDER BY incorporation_year;

SELECT
    EXTRACT(YEAR FROM c.incorporation_date) AS incorporation_year,
    ROUND(AVG(r.composite_risk_score), 2) AS avg_composite_risk
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
GROUP BY incorporation_year
ORDER BY incorporation_year;
```

## PEP Director Presence in Companies

Since we flagged directors as politically exposed persons (PEPs) in our dimension, we can create a pie chart or bar chart showing the proportion of companies that have at least one PEP director versus those that do not.

Pie Chart or Bar Chart


```sql
SELECT
    CASE
        WHEN d.is_pep = 1 THEN 'Has PEP Director'
        ELSE 'No PEP Director'
    END AS pep_status,
    COUNT(DISTINCT d.company_id) AS company_count
FROM dim_director d
GROUP BY pep_status;
```

## Composite Risk by Location Risk Level

By joining our company and location dimensions, we can analyze how the average composite risk score varies by the inherent risk level of the location (e.g., High, Medium). This visualization can be a grouped bar chart to compare the average risk across different location risk levels.

```sql
SELECT
    l.risk_level,
    AVG(r.composite_risk_score) AS avg_composite_risk
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
JOIN dim_location l
    ON c.city = l.city
    AND c.country_code = l.country_code
GROUP BY l.risk_level;

SELECT
    l.risk_level,
    ROUND(AVG(r.composite_risk_score), 2) AS avg_composite_risk
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
JOIN dim_location l
    ON c.city = l.city
    AND c.country_code = l.country_code
GROUP BY l.risk_level;
```

## Profit Margin vs. Composite Risk Scatter Plot

We can create a scatter plot that juxtaposes each company’s average profit margin against its composite risk score. Companies that combine a low (or negative) profit margin with a high composite risk score could be flagged as anomalous, warranting closer investigation.

Scatter Plot

```sql
WITH avg_profit AS (
    SELECT
         company_id,
         AVG(profit_margin) AS avg_profit_margin
    FROM int_financial_metrics
    GROUP BY company_id
)
SELECT
    c.company_name,
    r.composite_risk_score,
    ap.avg_profit_margin
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
JOIN avg_profit ap
    ON r.company_id = ap.company_id
ORDER BY r.composite_risk_score DESC;
```


# Multiple Directorship Analysis

A director serving on multiple company boards can sometimes signal potential conflicts of interest or even networks used to obscure fraudulent activities. We can produce a bar chart highlighting directors with memberships across several companies.

Bar Chart


```sql
SELECT
    CONCAT(first_name, ' ', last_name) AS director_name,
    COUNT(DISTINCT company_id) AS company_count
FROM dim_director
GROUP BY director_name
HAVING COUNT(DISTINCT company_id) > 1
ORDER BY company_count DESC;
```


# PEP Financial Performance Comparison

By comparing the average profit margins of companies with and without politically exposed persons (PEP) on their boards, we might detect whether PEP involvement correlates with abnormal financial performance. A box plot will help visualize the distribution of profit margins across these two groups.

Box Plot


```sql
WITH pep_companies AS (
    SELECT DISTINCT
         company_id
    FROM dim_director
    WHERE is_pep = 1
),
avg_profit AS (
    SELECT
         company_id,
         AVG(profit_margin) AS avg_profit_margin
    FROM int_financial_metrics
    GROUP BY company_id
)
SELECT
    CASE WHEN p.company_id IS NOT NULL THEN 'Has PEP Director'
         ELSE 'No PEP Director'
    END AS pep_status,
    ap.avg_profit_margin
FROM avg_profit ap
LEFT JOIN pep_companies p
    ON ap.company_id = p.company_id;
```

# New vs. Established Companies Risk Comparison

A surge in new companies with high composite risk scores might indicate a wave of potentially fraudulent registrations. By comparing the average composite risk of companies incorporated recently against established ones, we can assess whether newer entities are more prone to high-risk signals.

Bar Chart or Box Plot

```sql
SELECT
    CASE 
        WHEN EXTRACT(YEAR FROM c.incorporation_date) >= EXTRACT(YEAR FROM CURRENT_DATE) - 5 THEN 'New (<=5 yrs)'
        ELSE 'Established (>5 yrs)'
    END AS company_age_group,
    AVG(r.composite_risk_score) AS avg_composite_risk,
    COUNT(*) AS company_count
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
GROUP BY company_age_group;
```

# Revenue Volatility vs. Composite Risk Scatter Plot

We can calculate the revenue volatility (using the standard deviation of revenue over time) for each company and then plot that against the composite risk score. Companies with both high revenue volatility and high composite risk scores may warrant additional investigation as potential fraud cases.

Scatter Plot or Bubble Chart (with bubble size or color representing revenue volatility)

```sql
WITH revenue_stats AS (
    SELECT
        company_id,
        STDDEV(revenue) AS revenue_volatility,
        AVG(revenue) AS avg_revenue
    FROM int_financial_metrics
    GROUP BY company_id
)
SELECT
    c.company_name,
    r.composite_risk_score,
    rs.revenue_volatility,
    rs.avg_revenue
FROM fact_risk_assessments r
JOIN revenue_stats rs
    ON r.company_id = rs.company_id
JOIN dim_company c
    ON r.company_id = c.company_id
ORDER BY rs.revenue_volatility DESC;
```

# Profit Margin Distribution by Country

A box plot comparing average profit margins by country can highlight regions where companies deviate significantly from the norm. Unusual profit margin distributions may signal financial manipulation or irregularities that could be associated with fraudulent behavior.

Box Plot

```sql
WITH company_profit AS (
    SELECT
        company_id,
        AVG(profit_margin) AS avg_profit_margin
    FROM int_financial_metrics
    GROUP BY company_id
)
SELECT
    c.country_code,
    cp.avg_profit_margin
FROM company_profit cp
JOIN dim_company c
    ON cp.company_id = c.company_id;
```

## Heatmap of Composite Risk by City and Incorporation Year

This heatmap visualizes the average composite risk score by city and the year of incorporation. By grouping companies across these dimensions, we can quickly identify clusters—such as specific cities or time periods—where companies tend to exhibit higher risk levels. These clusters might serve as indicators of potential fraudulent behavior or other irregularities.

```sql
SELECT
    c.city,
    EXTRACT(YEAR FROM c.incorporation_date) AS incorporation_year,
    AVG(r.composite_risk_score) AS avg_composite_risk
FROM fact_risk_assessments r
JOIN dim_company c
    ON r.company_id = c.company_id
GROUP BY c.city, incorporation_year
ORDER BY c.city, incorporation_year;
```
