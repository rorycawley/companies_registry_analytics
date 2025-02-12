{{ config(materialized='table') }}

SELECT
    company_id,
    company_name,
    incorporation_date,
    street_address,
    city,
    country_code
FROM {{ ref('stg_companies') }}
