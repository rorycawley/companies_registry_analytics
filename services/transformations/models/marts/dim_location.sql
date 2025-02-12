{{ config(materialized='table') }}

SELECT DISTINCT
    city,
    country_code,
    risk_level
FROM {{ ref('stg_risky_locations') }}
