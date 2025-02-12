{{ config(materialized='table') }}

-- We join directors with the PEP staging model to flag politically exposed individuals. 
-- A simple matching on first and last name could serve as a starting point.
-- We could further refine this model by including additional logic 
-- based on the director’s nationality (joined with our country_codes seed) if needed.

WITH directors AS (
    SELECT
        director_id,
        company_id,
        first_name,
        last_name,
        appointment_date,
        nationality
    FROM {{ ref('stg_directors') }}
),
peps AS (
    SELECT
        first_name AS pep_first_name,
        last_name AS pep_last_name,
        position,
        country_name
    FROM {{ ref('stg_peps') }}
)
SELECT
    d.*,
    CASE
        WHEN p.pep_first_name IS NOT NULL THEN 1
        ELSE 0
    END AS is_pep
FROM directors d
LEFT JOIN peps p
    ON LOWER(d.first_name) = LOWER(p.pep_first_name)
    AND LOWER(d.last_name) = LOWER(p.pep_last_name)
