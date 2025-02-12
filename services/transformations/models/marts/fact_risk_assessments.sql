{{ config(materialized='table') }}

-- This fact table can later be joined to dimension tables on company details, time, or location as needed.

SELECT
   company_id,
   composite_risk_score,
   TRY_STRPTIME(CURRENT_DATE, '%Y-%m-%d') AS evaluation_date,
FROM {{ ref('int_company_risk') }}
