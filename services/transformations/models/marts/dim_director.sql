{{ config(materialized='table') }}

SELECT
    director_id,
    company_id,
    first_name,
    last_name,
    appointment_date,
    nationality,
    is_pep
FROM {{ ref('int_director_risk') }}
