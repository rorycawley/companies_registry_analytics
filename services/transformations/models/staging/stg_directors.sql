{{ config(materialized='table') }}

SELECT  director_id, 
        company_id, 
        first_name, 
        last_name, 
        TRY_STRPTIME(appointment_date, '%Y-%m-%d') AS appointment_date,
        nationality
FROM {{ source('ingested_data', 'raw_directors') }}