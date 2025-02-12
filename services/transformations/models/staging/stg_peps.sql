{{ config(materialized='table') }}

SELECT  first_name,
        last_name,
        position, 
        country AS country_name
FROM {{ source('ingested_data', 'raw_peps') }}