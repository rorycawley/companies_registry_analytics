{% docs risk_assessment_methodology %}
Our risk assessment system combines three key risk factors to evaluate company risk profiles:

1. Location Risk (30% of composite score)
The location risk assessment evaluates both the city and country where a company operates:
- High-risk cities (e.g., Kabul, Baghdad) automatically assign a maximum risk score of 100
- Medium-risk cities (e.g., Rio de Janeiro, Manila) assign a score of 50
- Country-level risk contributes when no specific city match exists
- Risk scores are normalized to a 0-100 scale

2. Financial Risk (40% of composite score)
Financial risk evaluation examines both current metrics and historical trends:
- Profit margin thresholds:
  * Below 5%: High risk (score: 75-100)
  * 5-15%: Medium risk (score: 25-74)
  * Above 15%: Low risk (score: 0-24)
- Three-period trend analysis affects the base score:
  * Declining trend: +25 points
  * Stable trend: no adjustment
  * Improving trend: -25 points

3. PEP Risk (30% of composite score)
PEP risk assessment identifies and scores politically exposed person associations:
- Direct PEP match (exact name match): 100 points
- Probable PEP match (>90% name similarity): 75 points
- Possible PEP match (>80% name similarity): 50 points
- Multiple PEP associations increase the score by 25 points
{% enddocs %}

{% docs intermediate_transformations %}
Our intermediate models transform staging data into risk metrics through several steps:

1. int_company_location_risk:
- Matches company addresses against risky_locations database
- Implements fuzzy matching for city names to handle spelling variations
- Applies hierarchical scoring (city match takes precedence over country)
- Calculates normalized location risk scores

2. int_director_pep_matches:
- Performs name matching between directors and PEP list
- Uses fuzzy string matching with Levenshtein distance
- Considers nationality and other factors for match confidence
- Aggregates multiple PEP associations at company level

3. int_financial_risk_metrics:
- Calculates rolling profit margins
- Determines trend directions using 3-period analysis
- Normalizes financial metrics against industry benchmarks
- Generates composite financial risk scores
{% enddocs %}

{% docs mart_model_usage %}
Our mart models serve different analytical needs:

1. fact_risk_assessments:
- Provides daily risk score snapshots
- Enables trend analysis and risk evolution tracking
- Serves as the primary source for risk monitoring dashboards
- Supports regulatory reporting requirements

2. dim_company:
- Maintains historical record of company attributes
- Tracks changes in risk status over time
- Supports dimensional analysis of risk factors
- Enables point-in-time reporting capabilities

Use Cases:
- Risk Monitoring: Track companies exceeding risk thresholds
- Trend Analysis: Identify patterns in risk score evolution
- Regulatory Reporting: Generate required compliance reports
- Due Diligence: Support enhanced due diligence processes
{% enddocs %}

{% docs risk_score_calculation %}
The composite risk score calculation follows a weighted methodology:

1. Base Score Calculation:
   Location Risk (30%):
   - High-risk city: 100 points
   - Medium-risk city: 50 points
   - Country risk: 25-75 points based on risk level
   
   Financial Risk (40%):
   - Profit Margin Score (60% of financial risk):
     * <5%: 100 points
     * 5-15%: 50 points
     * >15%: 0 points
   - Trend Score (40% of financial risk):
     * Declining: +25 points
     * Stable: 0 points
     * Improving: -25 points
   
   PEP Risk (30%):
   - Direct PEP match: 100 points
   - Probable match: 75 points
   - Possible match: 50 points
   - Multiple PEPs: +25 points

2. Final Score:
   - Weighted average of all components
   - Normalized to 0-100 scale
   - Rounded to nearest integer

3. Risk Categories:
   - Low: 0-30
   - Medium: 31-70
   - High: 71-100
{% enddocs %}