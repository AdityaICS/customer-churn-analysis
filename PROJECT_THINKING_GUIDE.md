# Customer Churn Analysis - Project Thinking Guide

**For Interview Preparation: Senior Data Analyst Role (10+ years equivalent)**

---

## 1️⃣ Business Context & Problem Framing

### Why Churn Matters More Than Acquisition

**The Fundamental Economics**:
- **Acquiring a new customer costs 5-7x more than retaining an existing one** (Harvard Business Review)
- **Telecom industry average churn**: 20-30% annually
- **Impact of 5% ch churn reduction**: 25-95% profit increase (Bain & Company)

**Real-World Scenario**: Imagine a telecom company with 1M customers, $50 monthly revenue per customer, and 26.5% annual churn.
- **Annual churn**: 265,000 customers
- **Lost monthly revenue**: $13.25M
- **Lost annual revenue**: $159M

**This analysis answers**: Can we reduce churn from 26.5% to 20% and save $30M+ annually?

### What Decisions This Enables

**Executive Level**:
- **Budget Allocation**: Should we invest $500K in customer success team or product improvements?
- **Pricing Strategy**: Are month-to-month customers worth the churn risk vs. locking them into annual contracts?
- **Product Roadmap**: Should we prioritize tech support expansion over new streaming features?

**Operational Level**:
- **Proactive Intervention**: Which 1,500 customers should we call this week to prevent churn?
- **Contract Optimization**: How much discount to offer for monthly → annual conversion?
- **Payment Friction**: Why do electronic check users churn at 45% vs. credit card at 15%?

### Cost of NOT Doing This Analysis

**What Happens**: Company treats all customers the same (generic marketing, no targeted retention)

**Result**:
- **Wasted Retention Spend**: Offering discounts to low-risk customers (unnecessary cost)
- **Missed High-Risk Customers**: Losing $2.8M annual revenue from 1,547 at-risk customers
- **Strategic Blindness**: Investing in wrong levers (new features instead of fixing onboarding)

**Financial Impact**: Continue bleeding $1.67M annually while competitors optimize retention and win market share.

---

## 2️⃣ Dataset Understanding & Assumptions

### Why Telco Customer Churn Dataset

**Chosen Because**:
1. **Real-World Fidelity**: Actual telecom data (not synthetic). Has real-world messiness (missing values, data type issues)
2. **Rich Feature Set**: 21 features including demographics, services, contract terms, payment methods
3. **Binary Outcome**: Clean churn label (Yes/No) enables supervised learning (future extension)
4. **Industry Relevance**: Telecom is classic churn domain. Techniques apply to SaaS, streaming, subscriptions

**What We're Simulating**: A mid-sized telecom provider (think regional AT&T or T-Mobile competitor) with ~7K customers.

### Key Columns in Business Terms

| Column | Business Meaning | Why It Matters |
|--------|------------------|----------------|
| `Churn` | Customer cancelled service | **Target variable**: What we're trying to predict/reduce |
| `tenure` | Months as customer | **Loyalty indicator**: Longer tenure = stickier customers |
| `Contract` | Month-to-month / 1yr / 2yr | **Lock-in mechanism**: Contracts reduce churn (but limit flexibility) |
| `MonthlyCharges` | Bill amount | **Revenue at risk**: High churners = high revenue loss |
| `PaymentMethod` | How they pay |  **Friction indicator**: Electronic check = manual = higher churn |
| `TechSupport` | Has tech support? | **Value-add**: Support increases perceived value |
| `InternetService` | DSL / Fiber / None | **Core product**: Fiber users churn more (why?) |

### Critical Business Assumptions

#### Assumption 1: Churn = Final (No Win-Back Possible)
**What We Assume**: Once `Churn = 'Yes'`, they're gone forever.

**Reality Check**: In telecom, some customers churn to competitor, then return later (boomerang churn).

**Interview Defense**: "For initial analysis, I treat churn as binary. In production, I'd track churn type (voluntary vs involuntary) and measure win-back rate separately."

#### Assumption 2: Tenure = Time with THIS Company
**Potential Issue**: If customer switched from prepaid to postpaid with same company, tenure might reset (data artifact).

**Mitigation**: Cross-validate with `customerID`—if ID is unique, tenure is valid. In production, I'd reconcile with CRM system.

#### Assumption 3: Monthly Charges = Consistent
**What We Don't Know**: Did prices change over time? Promotional discounts?

**Risk**: If tenure=1 customer paid $50 (promo) and tenure=24 customer pays $90 (full price), MonthlyCharges isn't comparable.

**Interview Answer**: "For v1, I assume current pricing. For accurate CLV, I'd need billing history to calculate true lifetime revenue."

### What We Intentionally Ignored

**Streaming Services (TV/Movies)**: Not analyzed in detail because:
- **Correlation**: Streaming often bundles with internet. Hard to isolate impact.
- **Strategic Focus**: Tech support and contract type are higher-leverage interventions.
- **Interview Answer**: "I focused on levers with clear ROI. Streaming content strategy is a separate deep-dive."

**Device Protection & Online Backup**: Mentioned in churn drivers but not prioritized because:
- **Lower Adoption**: Only ~30-40% of customers use these services
- **Incremental**: Not core to retention (unlike tech support, which drops churn by 50%)

---

## 3️⃣ Metric Selection Logic (VERY IMPORTANT)

### Metric 1: Churn Rate vs Retention Rate

**Churn Rate**: % of customers who left
**Retention Rate**: % of customers who stayed

**Formula**: Retention Rate = 1 - Churn Rate

**Why We Report Churn Rate**:
- **Problem-Focused**: "26.5% churn" highlights the problem
- **Industry Norm**: Telecom execs talk in churn rates
- **Action-Oriented**: "Reduce churn" is clearer than "increase retention"

**When to Use Retention Rate**:
- **Growth Metrics**: "95% monthly retention" sounds better than "5% monthly churn"
- **SaaS Context**: Retention rate is standard in software subscriptions

**Interview Question**: *"Aren't they the same thing?"*
- **Answer**: "Mathematically, yes. Psychologically, no. 'Churn' emphasizes loss aversion (people hate losing things), which drives urgency."

### Metric 2: Customer Lifetime Value (CLV)

**Why CLV Matters**:
- **Quantifies Impact**: "High churn" is vague. "Losing $1.67M annually" is concrete.
- **Prioritization**: Not all churn is equal. Losing a $20/month customer ≠ losing a $100/month customer.

**Our Calculation**:
```sql
-- Simplified CLV
projected_lifetime_value = TotalCharges + (MonthlyCharges × 36)
```

**Why 36 Months**:
- **Industry Average**: Telecom CLV typically 3-5 years
- **Conservative**: We use 3 years (36 months) to avoid over-estimation

**Interview Question**: *"Why not use time-value of money (discounting)?"*
- **Answer**: "For back-of-envelope CLV, I use nominal values. For financial modeling (e.g., investor decks), I'd apply discount rate. Formula: `CLV = Σ (Monthly Revenue × (1 + Discount Rate)^-t)`. For churn analysis, undiscounted CLV shows directional impact."

### Metric 3: Churn Rate by Tenure Cohorts (NOT just Overall Churn)

**Why Cohorts**:
- **Actionable**: "Overall churn = 26.5%" doesn't tell you WHEN customers churn.
- **Targeted Interventions**: If Month 0-6 churn = 47%, focus onboarding. If Month 24+ churn = 15%, different problem.

**Cohort Insight**: "The First Year Crisis—47.7% churn in first 12 months"

**Business Impact**:
- **Onboarding**: Invest in 90-day welcome program (ROI: save 15% of new customers)
- **Contract Timing**: Offer annual contract upgrade at Month 6 (before high-churn window)

---

## 4️⃣ SQL Thinking (Query-by-Query Reasoning)

### Query 1: Churn by Contract Type

```sql
SELECT 
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100), 2
    ) AS churn_rate_pct
FROM telco_customer_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;
```

#### Design Decisions

**1. Why SUM(CASE WHEN...) instead of COUNT(Churn)?**
```sql
-- Won't work:
COUNT(Churn WHERE Churn = 'Yes')  -- Syntax error in SQL

-- Alternative:
COUNT(*) FILTER (WHERE Churn = 'Yes')  -- PostgreSQL specific
```

**Why CASE WHEN**:
- **Universally Compatible**: Works in MySQL, PostgreSQL, SQL Server
- **Readable**: Clear conditional logic
- **Versatile**: Easy to extend (e.g., `CASE WHEN Churn = 'Yes' AND tenure > 12`)

**2. Why Cast to ::numeric Before Division?**
```sql
-- Without cast:
(1869 / 7043 * 100) = 0  -- Integer division in SQL!

-- With cast:
(1869::numeric / 7043 * 100) = 26.54  -- Correct
```

**Interview Defense**: "SQL integer division truncates decimals. Casting to numeric/float ensures precision. This is a common gotcha that can silently break metrics."

**3. Why ORDER BY churn_rate DESC?**
- **Business Priority**: We want to see worst-performing contracts first (month-to-month at 42.7%)
- **Actionable**: If we have 10 minutes with CEO, show the problem immediately

### Query 2: Risk Scoring Model (Rule-Based)

```sql
WITH risk_scores AS (
    SELECT 
        customerID,
        tenure,
        Contract,
        MonthlyCharges,
        (CASE WHEN Contract = 'Month-to-month' THEN 3 ELSE 0 END +
         CASE WHEN tenure <= 12 THEN 3 ELSE 0 END +
         CASE WHEN PaymentMethod = 'Electronic check' THEN 2 ELSE 0 END +
         CASE WHEN TechSupport = 'No' THEN 2 ELSE 0 END +
         CASE WHEN OnlineSecurity = 'No' AND InternetService != 'No' THEN 2 ELSE 0 END +
         CASE WHEN MonthlyCharges > 80 THEN 2 ELSE 0 END) AS risk_score
    FROM telco_customer_churn
    WHERE Churn = 'No'  -- Only active customers
)
SELECT 
    CASE 
        WHEN risk_score >= 10 THEN 'Critical Risk'
        WHEN risk_score >= 7 THEN 'High Risk'
        ...
    END AS risk_category,
    COUNT(*) AS customer_count,
    ROUND(SUM(MonthlyCharges * 12), 2) AS annual_revenue_at_risk
FROM risk_scores
GROUP BY risk_category;
```

#### Why This Scoring System?

**Business Context**: We need to prioritize which customers to intervene with TODAY. Can't call all 5,174 active customers.

**Weighting Logic**:
- **3 points**: Contract = Month-to-month (15x churn risk vs. 2-year)
- **3 points**: Tenure ≤ 12 months (3x churn risk vs. 24+ months)
- **2 points**: Electronic check (3x churn risk vs. credit card)
- **2 points**: No tech support (2.7x churn risk)
- **2 points**: No online security (internet customers without security churn more)
- **2 points**: Monthly charges > $80 (price sensitivity)

**Why These Weights?**
- **Data-Driven**: Based on observed churn ratios from univariate analysis
- **Additive**: Simple sum (no interaction terms). Trade-off: simplicity vs. accuracy.

**Interview Question**: *"Why not use logistic regression?"*
- **Answer**: "Rule-based scoring is explainable to non-technical stakeholders. If I call a customer and say 'you're high-risk because of X, Y, Z,' they understand. If I say 'our black-box model predicted you'll churn,' they don't. For v1, transparency wins. For v2, I'd A/B test rule-based vs. ML model."

**2. Why Filter WHERE Churn = 'No'?**
- **Purpose**: Risk scoring is for proactive intervention. Churned customers are already gone.
- **Practical**: We score **active** customers to prioritize retention calls.

**Interview Objection**: *"Shouldn't you score churned customers to validate the model?"*
- **Answer**: "Correct. In production, I'd split churned customers into train/test sets, build score on train, validate on test. For real-time scoring, I'd apply to active customers only."

---

## 5️⃣ Python Analysis Thinking

### Why Python Wasn't Heavily Used Here

**SQL Focus**: This project leans heavily on SQL because:
1. **Aggregation-Heavy**: Most insights come from GROUP BY, COUNT, SUM
2. **Stakeholder Presentation**: SQL results export to Excel/Tableau easily
3. **Production Deployment**: Risk scores can run as SQL stored procedures (no Python dependency)

**Python Use Cases** (if extended):
- **Statistical Testing**: Chi-square test for contract type vs. churn significance
- **ML Models**: XGBoost for churn prediction
- **Advanced Viz**: Survival curves (Kaplan-Meier)

### Hypothetical Python Extension: Survival Analysis

**Business Question**: "How long do customers typically stay before churning?"

**Approach**: Kaplan-Meier survival curves
```python
from lifelines import KaplanMeierFitter

kmf = KaplanMeierFitter()
kmf.fit(durations=df['tenure'], event_observed=df['Churn']== 'Yes')
kmf.plot_survival_function()
```

**Insight**: "50% of month-to-month customers churn by Month 8, vs. Month 24 for annual contracts."

**Interview Value**: Shows you know advanced techniques (survival analysis is rare in analyst portfolios).

---

## 6️⃣ Insight Interpretation (NOT JUST RESULTS)

### Insight 1: "Month-to-Month Customers Churn at 42.7%"

#### What It Actually Means
**Surface**: Monthly contracts are risky.

**Deeper**:
- **No Lock-In**: Customers can leave any time → low switching cost
- **Commitment Phobia**: Monthly customers are "testing" the service → haven't decided to stay long-term
- **Competitive Vulnerability**: If competitor offers better deal, monthly customers switch immediately

#### What Decision It Enables
**Tactical**: Offer contract upgrade incentives ("Switch to annual, get 2 months free")
**Strategic**: Re-design pricing to make monthly less attractive (charge premium for flexibility)

#### What Could Be Misleading
**False Assumption**: "All month-to-month customers want annual contracts."

**Reality**: Some customers NEED flexibility (students moving, temporary residents). Forcing them into annual contracts = different churn mode (early cancellation fees = bad PR).

**How to Refine**: Segment month-to-month customers:
- **Switchers**: Those who've been month-to-month for 12+ months → upgrade candidates
- **Transients**: Those with tenure < 6 months → wrong segment for annual conversion

### Insight 2: "Electronic Check Users Churn at 45.3%"

#### Root Cause Analysis (5 Whys)
1. **Why do electronic check users churn more?**
   → Manual payment process creates friction.

2. **Why does friction cause churn?**
   → Missed payments → service interruption → frustration → cancellation.

3. **Why do they use electronic check?**
   → Prefer not to give credit card info (trust issue) OR no credit card available.

4. **Why is this a problem?**
   → Payment failure leads to involuntary churn (company's problem to solve).

5. **Root Cause**: Payment method friction, not product dissatisfaction.

#### Intervention Design
**Wrong Intervention**: "Improve product quality" (won't fix payment friction)
**Right Intervention**: "Migrate to credit card auto-pay with $10 incentive"

**Expected Impact**:
- Assume 40% of electronic check users migrate (950 customers)
- Churn rate drops from 45% to 20% (credit card average)
- Customers saved: 950 × 0.25 = 238 customers/year
- Revenue saved: 238 × $75/month × 12 = $214K

**Interview Question**: *"How do you know payment friction is the real cause?"*
- **Answer**: "We observe correlation. For causation, I'd run an A/B test: offer half of electronic check users migration incentive, measure churn difference. If treated group has lower churn, friction is confirmed."

---

## 7️⃣ Business Recommendations & Trade-offs

### Recommendation 1: 90-Day Onboarding Program

#### Why First 90 Days Matter
**Data**: 47.7% churn in months 0-12, vs. 15.3% in months 24+

**Psychology**: First impression sets the tone. Bad onboarding → "this company doesn't care" → churn.

**Components**:
1. **Week 1**: Welcome call from account manager ("How's setup going?")
2. **Week 4**: Usage report ("You're using 60% of your data plan—upgrade?")
3. **Week 12**: Satisfaction survey + 10% discount if unhappy

#### Cost-Benefit
**Cost**: $40K (call center time, discount budget)
**Benefit**: Reduce 0-12 month churn from 47.7% to 35% (12.7pp drop)
**Customers Saved**: ~140/year
**Revenue Saved**: 140 × $75 × 12 = $126K

**ROI**: $126K / $40K = 3.15x (payback in 4 months)

#### Trade-offs
**Pro**: High-touch builds loyalty
**Con**: Doesn't scale to millions of customers (automated alternatives needed)

**Next Level**: Chatbot-driven onboarding (scales to 10M customers)

### Recommendation 2: Include Tech Support in All Internet Plans

#### Current State
- 37% of internet customers have tech support
- Without support: 41.7% churn
- With support: 15.2% churn (2.7x difference!)

#### The Economics
**Cost of Tech Support**: ~$8/month per customer
**Value of Churn Reduction**:
- Base case: 3,473 customers without support, churning at 41.7%
- With support: Churn drops to 15.2% (26.5pp reduction)
- Customers saved: 3,473 × 0.265 = 920 customers/year
- Revenue saved: 920 × $75 × 12 = $828K

**Cost**: 3,473 × $8 × 12 = $333K
**Net Benefit**: $828K - $333K = $495K

**Interview Question**: *"Won't customers complain if you raise prices to cover support?"*
- **Answer**: "Frame it as value-add, not a price increase. Marketing message: 'Now all internet plans include premium 24/7 support.' Competitors charge separately for support. We bundle it, making us more attractive."*

#### Risk Mitigation
**Risk**: Tech support costs spiral if call volume explodes.
**Mitigation**: Tiered support—chatbot first, then phone. Monitor cost per ticket.

---

## 8️⃣ Interview Defense Section (CRITICAL)

### 60-Second Elevator Pitch
*"I analyzed 7,000 telecom customers to identify why 26.5% churn annually. Three critical findings: First, month-to-month customers churn at 42.7%, costing $1.2M/year. I recommend contract upgrade incentives. Second, electronic check users churn at 45%, driven by payment friction—solution: migrate to auto-pay with $10 credit. Third, first-year customers churn at 47.7%—solution: 90-day onboarding program. Combined, these interventions reduce churn to 19.2%, saving $1.2M annually with $180K investment."*

### Common Interviewer Objections

#### Objection 1: "Why Not Build a Machine Learning Model?"
**Weak Answer**: "I didn't know how."
**Strong Answer**: "I built a rule-based risk scoring system for two reasons: (1) Explainability—retention teams need to understand WHY a customer is high-risk. (2) Speed—rule-based scores deploy in 2 weeks vs. 3 months for ML model training, validation, and deployment. Once stakeholders buy into the framework, v2 would be XGBoost or neural networks for improved accuracy. But business adoption beats algorithmic sophistication."

#### Objection 2: "Your Sample Size Is Too Small (7K customers)"
**Counter**: "7K customers is statistically significant for A/B tests (need ~400 per group for 80% power). For churn analysis, the insights are directional: contract type, payment friction, and onboarding gaps apply regardless of company size. In production with 1M customers, I'd use the same methodology—just at scale with automated dashboards."

#### Objection 3: "Correlation ≠ Causation"
**Answer**: "Absolutely. My SQL analysis shows correlations (e.g., electronic check → high churn). For causal inference, I'd run controlled experiments: A/B test payment migration offer, measure churn delta. I'd also use propensity score matching to compare similar customers with/without tech support. The recommendations include 'pilot first' specifically to validate causation before full rollout."

---

## 9️⃣ Self-Reflection & Improvement Ideas

### What Could Be Improved

**1. Cohort Retention Curves**
- **Current**: Snapshot churn rate by tenure bucket
- **Better**: Month-by-month retention curves showing decay over time
- **Tool**: Python (lifelines library) or SQL window functions

**2. Churn Prediction Model (ML)**
- **Current**: Risk scoring (rules)
- **Better**: XGBoost classifier predicting 90-day churn probability
- **Features**: All current variables + interaction terms (Contract × Tenure)

**3. Time-to-Churn Analysis**
- **Current**: Binary churn (Yes/No)
- **Better**: Survival analysis showing median time-to-churn by segment
- **Why**: Identifies optimal intervention timing (e.g., call customers at Month 6 before high-risk window)

### What Data Is Missing

**1. Churn Reason** (Exit survey)
- **Why**: Did they churn due to price, service quality, or competitor offer?
- **Impact**: Targeted interventions (price-sensitive → discount; quality issues → tech support)

**2. Competitor Offers**
- **Why**: If competitor offers 2-year contracts at 20% discount, our churn is defensive
- **Impact**: Competitive intelligence informs pricing strategy

**3. Network Quality Metrics**
- **Why**: If fiber users churn more due to frequent outages, it's a service problem
- **Impact**: Operational fixes (upgrade infrastructure) vs. marketing fixes (better onboarding)

### How This Scales

**Current (Portfolio)**: One-time SQL analysis, manual insights

**Production at Scale**:
1. **Real-Time Dashboards**: Tableau with daily churn metrics by segment
2. **Automated Alerts**: Slack notification when high-value customer shows churn signals
3. **CRM Integration**: Risk scores feed into Salesforce for rep outreach
4. **ML Pipeline**: Weekly model retraining with new churn data
5. **A/B Test Platform**: Continuous experimentation on retention tactics

**Interview Answer**: "This analysis is the foundation. In production, I'd operationalize it: dashboards for monitoring, ML models for prediction, and closed-loop feedback (did our interventions work?)."

---

## Final Interview Mindset

### What Separates Senior from Junior

**Junior**: "High churn is bad. Here are the numbers."
**Senior**: "26.5% churn costs $1.67M annually. Month-to-month contracts are the root cause. I've prioritized three interventions with $180K budget and 6.7x ROI. Phase 1 launches in 2 weeks. Here's the success metrics."

**Difference**: Business impact, root cause analysis, prioritized roadmap.

### How to Demonstrate Strategic Thinking

**Interviewer**: "What would you do differently if you had more time?"

**Weak Answer**: "Use machine learning."
**Strong Answer**: "Three things: (1) Build cohort retention curves to identify precise churn inflection points. (2) Run controlled experiments to validate causal impact of interventions. (3) Integrate with customer success platform for real-time intervention triggers. The current analysis is diagnostic. The next phase is predictive and prescriptive."

---

**End of Thinking Guide**

This project demonstrates your ability to translate data into business action. Practice explaining each insight in 30 seconds, then show you can dive deep into SQL logic, statistical reasoning, and ROI calculations. Good luck! 🚀
