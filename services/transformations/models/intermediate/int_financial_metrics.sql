{{ config(materialized='table') }}

-- Here we compute key metrics (for example, profit margin) that might indicate financial risk. 
-- Normalizing these metrics will help when we combine them into a composite risk score.
-- We might later aggregate these financial metrics per company 
-- (for example, average profit margin over several periods) as part of a composite risk score.

SELECT
    company_id,
    report_date,
    revenue,
    profit,
    CASE
        WHEN revenue = 0 THEN 0
        ELSE profit / revenue
    END AS profit_margin
FROM {{ ref('stg_financials') }}
