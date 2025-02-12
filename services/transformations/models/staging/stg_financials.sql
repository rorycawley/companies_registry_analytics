{{ config(materialized='table') }}

SELECT  financial_id, 
        company_id, 
        TRY_STRPTIME(report_date, '%Y-%m-%d') AS report_date,
        revenue, 
        profit
FROM {{ source('ingested_data', 'raw_financials') }}