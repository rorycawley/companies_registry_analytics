{{ config(materialized='table') }}

SELECT  city,
        country AS country_code,
        risk_level
FROM {{ source('ingested_data', 'raw_risky_locations') }}