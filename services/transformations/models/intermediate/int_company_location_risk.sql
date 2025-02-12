{{ config(materialized='table') }}

-- We might calculate a risk score for companies based on their registered location. 
-- We could join stg_companies to stg_risky_locations and 
-- optionally use the country_codes seed to ensure our country codes match across datasets.


WITH companies AS (
    SELECT
        company_id,
        company_name,
        city,
        country_code
    FROM {{ ref('stg_companies') }}
),
risky_locations AS (
    SELECT
        city,
        country_code,
        risk_level,
        CASE
            WHEN risk_level = 'High' THEN 2
            WHEN risk_level = 'Medium' THEN 1
            ELSE 0
        END AS location_risk_score
    FROM {{ ref('stg_risky_locations') }}
)
SELECT
    c.company_id,
    c.company_name,
    c.city,
    c.country_code,
    COALESCE(rl.location_risk_score, 0) AS location_risk_score
FROM companies c
LEFT JOIN risky_locations rl
    ON c.city = rl.city
    AND c.country_code = rl.country_code
