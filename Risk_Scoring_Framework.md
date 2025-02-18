# Company Risk Scoring Framework Overview

Our risk framework is designed to quickly assess the overall risk profile of potential investments. By combining three key factors, we generate a composite score that helps identify companies that may require additional scrutiny.

---

## The Three Key Risk Factors

### 1. Location Risk

- **What It Assesses:**  
  The inherent risk of a company's geographical location.
  
- **How It's Scored:**  
  - **High-Risk Locations:** 2 points  
    *(Examples: Kabul, Tripoli, Donetsk)*  
  - **Medium-Risk Locations:** 1 point  
    *(Example: Johannesburg)*  
  - **Low or Unspecified Risk:** 0 points

### 2. Financial Health (Profit Margin)

- **What It Assesses:**  
  How efficiently a company converts revenue into profit. A higher profit margin indicates better financial health, whereas a lower margin suggests financial stress.

- **Calculation Steps:**  
  1. **Profit Margin Calculation:**  
     `Profit Margin = Profit / Revenue`
  2. **Average Profit Margin:**  
     For companies with multiple financial reports, we compute the average profit margin.
  3. **Financial Risk Score:**  
     We transform the profit margin into a risk score with this formula:  
     `Financial Risk Score = (1 - Average Profit Margin) × 2`
     
  - *Example:*  
    If the average profit margin is 15% (or 0.15), then:  
    `(1 - 0.15) × 2 ≈ 1.70`  
    Lower profit margins (i.e., closer to 0) yield a higher risk score.

### 3. Director Risk (Political Exposure)

- **What It Assesses:**  
  The presence of Politically Exposed Persons (PEPs) among a company's directors can introduce extra risk.

- **How It's Scored:**  
  - **No PEPs Detected:** 0 points  
  - **At Least One PEP Detected:** 3 points

*Note:* Our PEP list includes individuals such as Elaine Johnson, Buddy Love, Rory Cawley, Lukas Schmidt, Sophie Brown, John Smith, Isabelle Girard, and Charlotte Wilson.

---

## Composite Risk Score Calculation

The overall risk score is the sum of the weighted components:

- **Location Risk:** *Weight = 1*  
- **Financial Risk:** *Weight = 2 (via the transformed profit margin)*  
- **Director Risk:** *Weight = 3 (if any PEP is present)*

`Composite Risk Score = (Location Risk) + (Financial Risk Score) + (Director Risk Score)`

A lower total score indicates a lower risk profile, while a higher score signals increased risk that may require further investigation.

---

## Examples from Our Dataset

The table below illustrates how the composite risk score is calculated for three companies:

| Company | Location Risk | Average Profit Margin | Financial Risk Score<br>`(1-Margin)×2` | Director Risk | Total Composite Score |
|---------|---------------|----------------------|-------------------------------------|---------------|---------------------|
| **EuroFinance Group Ltd.** | 0 (London, GB is low risk) | ~15% (0.15) | (1 - 0.15)×2 ≈ **1.70** | 0 (No PEPs) | **0 + 1.70 + 0 = 1.70** |
| **Acme Holdings Ltd** | 1 (Johannesburg, ZA is medium risk) | ~15% (0.15) | (1 - 0.15)×2 ≈ **1.70** | 3 (John Smith is flagged) | **1 + 1.70 + 3 = 5.70** |
| **Kappa Industries SA** | 2 (Donetsk, UA is high risk) | ~15% (0.15) | (1 - 0.15)×2 ≈ **1.70** | 3 (Isabelle Girard is flagged) | **2 + 1.70 + 3 = 6.70** |

---

## Summary

- **Location Risk:**  
  Assesses the geopolitical environment. High-risk locations add more points.
  
- **Financial Health:**  
  Uses profit margin to quantify financial strength. A lower margin increases risk.
  
- **Director Risk:**  
  Flags potential governance issues if a company's directors include politically exposed individuals.
  
- **Composite Score:**  
  The combined score provides a straightforward metric to compare companies.  
  - **Lower scores** indicate low risk.  
  - **Higher scores** highlight companies that warrant closer examination.

This framework is designed to enable rapid, data-driven decision-making. The composite risk score helps us prioritize opportunities and mitigate potential downsides in our investment strategy.

