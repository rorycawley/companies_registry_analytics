{% docs source_companies_registry_data %}
The official companies registry database containing core information about registered companies, their directors, and financial reports.
{% enddocs %}

{% docs source_risk_data %}
External risk data sources including politically exposed persons (PEPs) and high-risk geographical locations.
{% enddocs %}

{% docs stg_companies %}
Cleaned and standardized company data from the registry, including:
- Basic company information
- Registration details
- Location data
{% enddocs %}

{% docs stg_directors %}
Standardized director information linked to companies:
- Director identification
- Company association
- Appointment details
{% enddocs %}

{% docs stg_financials %}
Standardized financial reports with key metrics:
- Revenue figures
- Profit data
- Reporting periods
{% enddocs %}

{% docs stg_peps %}
Cleaned politically exposed persons data with standardized country names and positions.
{% enddocs %}

{% docs stg_risky_locations %}
Standardized high-risk location data with:
- City and country information
- Risk level categorization (High/Medium)
{% enddocs %}

{% docs int_company_location_risk %}
Calculated location-based risk scores for companies:
- Joins company locations with risk data
- Assigns risk scores based on location
- Score range: 0-2 (0=low, 1=medium, 2=high)
{% enddocs %}

{% docs int_company_risk %}
Composite risk assessment combining multiple factors:
- Location risk (weight: 1x)
- Financial health (weight: 2x)
- PEP association (weight: 3x)
Final score range: 0-10
{% enddocs %}

{% docs int_director_risk %}
Director risk assessment focusing on PEP status:
- Matches directors against PEP list
- Flags politically exposed individuals
- Binary classification (0=not PEP, 1=PEP)
{% enddocs %}

{% docs int_financial_metrics %}
Derived financial risk indicators:
- Profit margins
- Normalized metrics for risk scoring
- Historical performance trends
{% enddocs %}

{% docs dim_company %}
Core company dimension containing:
- Company identifiers
- Names and registration details
- Location information
{% enddocs %}

{% docs dim_director %}
Director dimension including:
- Director details
- Company associations
- PEP status
{% enddocs %}

{% docs dim_location %}
Location dimension with:
- City and country data
- Risk level classifications
- Geographic reference data
{% enddocs %}

{% docs fact_risk_assessments %}
Daily snapshot of company risk assessments:
- Composite risk scores
- Evaluation timestamps
- Links to dimension tables
{% enddocs %}