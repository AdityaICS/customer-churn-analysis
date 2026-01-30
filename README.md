# 📉 Customer Churn Analysis - Telecom Industry

![Python](https://img.shields.io/badge/Python-3.8+-blue?logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange?logo=postgresql&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Analysis-green?logo=pandas&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-success)

> **Comprehensive churn analysis for telecommunications company | Predictive insights, retention strategies, SQL + Python**

---

## 🎯 Problem Statement

As a ** Data Analyst**, I analyzed customer churn data to answer critical business questions:

1. **Why are customers leaving?** Identify root causes of churn
2. **Which customers are at highest risk?** Build predictive risk models
3. **What is the financial impact?** Quantify revenue loss from churn
4. **How can we reduce churn?** Data-driven retention strategies
5. **What is the ROI of retention efforts?** Calculate break-even retention spend

**Current Situation**: 26.5% churn rate | **Goal**: Reduce to <20% | **Impact**: Save R$2.8M+ annually

---

## 📊 Dataset Overview

**Source**: [Telco Customer Churn Dataset (Kaggle)](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)

- **Customers**: 7,043
- **Features**: 21 (demographics, services, account info)
- **Churn Rate**: 26.5%
- **Time Period**: Current customer snapshot

---

## 🔍 Key Findings

### 1. Early Tenure is Critical
- **First 12 months**: 47.7% churn rate
- **After 24 months**: Only 15.3% churn
- **Insight**: Onboarding experience determines long-term retention

### 2. Contract Type Drives Retention
- **Month-to-month**: 42.7% churn
- **One year**: 11.3% churn
- **Two year**: 2.8% churn
- **Opportunity**: Convert 30% of monthly → annual contracts

### 3. Payment Method as Churn Indicator
- **Electronic check**: 45.3% churn (highest)
- **Credit card**: 15.2% churn (lowest)
- **Root cause**: Payment friction leads to churn

### 4. Service Bundling Reduces Churn
- **1-2 services**: 35% churn
- **5+ services**: 18% churn
- **Strategy**: Cross-sell for "stickiness"

### 5. Tech Support Significantly Reduces Churn
- **With tech support**: 15.2% churn
- **Without tech support**: 41.7% churn
- **ROI**: Tech support pays for itself through retention

### 6. High Revenue at Risk
- **Monthly revenue loss**: $139,130
- **Annual revenue loss**: $1.67M
- **Avg CLV per churned customer**: $1,531
- **Total customers at high risk**: 1,547 (worth $2.8M annually)

📊 **[View Full Insights](insights/final_insights.md)**

---

## 💡 Strategic Recommendations

### Phase 1: Quick Wins (Month 1)
1. **Welcome Onboarding Program** for first 90 days
   - Expected impact: Reduce early churn from 47.7% → 35%
   
2. **Automated Payment Method Migration**
   - Move electronic check users to credit card (incentive: $10 credit)
   - Expected impact: Save 300+ customers/year

### Phase 2: Contract Optimization (Month 2-3)
3. **Annual Contract Promotion**
   - Offer 2 months free for switching month-to-month → annual
   - Expected impact: Convert 1,200 customers, reduce churn by 8pp

4. **Service Bundle Upsell**
   - Recommend complementary services at renewal
   - Expected impact: Increase avg services from 3.2 → 4.5

### Phase 3: Risk-Based Interventions (Month 3-6)
5. **Predictive Churn Model Deployment**
   - Proactive outreach to high-risk customers
   - Retention offers: Discounts, upgrades, support

6. **Tech Support for All Internet Customers**
   - Include basic tech support in all internet plans
   - Expected impact: 15-20% churn reduction

### Projected Impact
**Churn Reduction**: 26.5% → 19.2% (-7.3pp)  
**Revenue Saved**: $1.2M annually  
**Investment Required**: $180K  
**ROI**: 6.7x

---

## 📁 Project Structure

```
customer-churn-analysis/
├── README.md
├── data/
│   └── dataset_info.txt
├── sql/
│   └── churn_queries.sql        # 8 comprehensive SQL analyses
├── notebooks/
│   └── churn_analysis.ipynb     # Python analysis with ML insights
└── insights/
    └── final_insights.md        # Detailed recommendations
```

---

## 🛠️ Tools & Technologies

Python 3.10+ | PostgreSQL | Pandas | Matplotlib | Seaborn | Scikit-learn (feature analysis)

---

## 🔄 How to Reproduce

1. Download [dataset from Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
2. Place CSV in `/data` directory
3. Run `sql/churn_queries.sql` for SQL analysis
4. Execute `notebooks/churn_analysis.ipynb` for Python analysis

---

## 🎓 Skills Demonstrated

✅ **SQL**: CTEs, window functions, risk scoring, cohort analysis  
✅ **Python**: Statistical analysis, churn prediction, visualization  
✅ **Business Strategy**: Retention economics, CLV optimization  
✅ **Stakeholder Communication**: Executive-ready insights with ROI

---

**⭐ Star this repo if you found it helpful for your portfolio!**
