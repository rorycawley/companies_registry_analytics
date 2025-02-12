{{ config(materialized='table') }}

-- Finally, we might combine our risk factors into a composite risk score per company. 
-- This model would join the location risk, aggregated financial metrics, 
-- and a summary of director risk (for instance, flagging companies that have one or more PEP directors).
-- Note: The composite risk score formula above is an example. 
-- We might adjust weights and calculations based on our domain expertise and evolving requirements.

WITH location AS (
    SELECT
        company_id,
        location_risk_score
    FROM {{ ref('int_company_location_risk') }}
),
financial AS (
    -- Aggregate financial metrics (e.g., average profit margin)
    SELECT
        company_id,
        AVG(profit_margin) AS avg_profit_margin
    FROM {{ ref('int_financial_metrics') }}
    GROUP BY company_id
),
director AS (
    -- Flag companies that have any PEP directors
    SELECT
        company_id,
        MAX(is_pep) AS has_pep
    FROM {{ ref('int_director_risk') }}
    GROUP BY company_id
)
SELECT
    c.company_id,
    c.company_name,
    COALESCE(l.location_risk_score, 0) AS location_risk_score,
    COALESCE(f.avg_profit_margin, 0) AS avg_profit_margin,
    COALESCE(d.has_pep, 0) AS has_pep,
    -- Example composite risk score calculation. We might weight a PEP flag more heavily.
    (COALESCE(l.location_risk_score, 0) * 1) +
    ((1 - COALESCE(f.avg_profit_margin, 0)) * 2) +
    (COALESCE(d.has_pep, 0) * 3) AS composite_risk_score
FROM {{ ref('stg_companies') }} c
LEFT JOIN location l ON c.company_id = l.company_id
LEFT JOIN financial f ON c.company_id = f.company_id
LEFT JOIN director d ON c.company_id = d.company_id
