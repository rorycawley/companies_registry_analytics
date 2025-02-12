{{ config(materialized='table') }}

SELECT  company_id,
        name AS company_name,
        TRY_STRPTIME(incorporation_date, '%Y-%m-%d') AS incorporation_date,
        street_address,
        city,
        country_code
FROM {{ source('ingested_data', 'raw_companies') }}