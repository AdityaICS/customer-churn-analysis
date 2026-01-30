/*
================================================================================
CUSTOMER CHURN ANALYSIS - SQL QUERIES (MySQL)
================================================================================
Project: Telecom Customer Churn Analysis
Author: Data Analyst Portfolio
Purpose: Production-quality SQL for churn prediction and customer retention
Dataset: Telco Customer Churn Dataset (Kaggle)

This file demonstrates:
- Churn rate calculations and segmentation
- Customer lifetime value (CLV) analysis
- Cohort analysis for retention tracking
- Identification of churn drivers
- Risk scoring for proactive retention
================================================================================
*/


-- ============================================================================
-- 1. OVERALL CHURN METRICS
-- ============================================================================

-- Basic Churn Rate and Customer Breakdown
-- Business Question: What is our current churn situation?

SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END) AS active_customers,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_revenue,
    ROUND(SUM(TotalCharges), 2) AS total_revenue_all_time
FROM telco_customer_churn;


-- Churn by Tenure Segments
-- Business Question: When do customers typically churn?

SELECT 
    CASE 
        WHEN tenure <= 6 THEN '0-6 months (New)'
        WHEN tenure <= 12 THEN '7-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 36 THEN '25-36 months'
        ELSE '37+ months (Loyal)'
    END AS tenure_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(TotalCharges), 2) AS avg_total_charges
FROM telco_customer_churn
GROUP BY 
    CASE 
        WHEN tenure <= 6 THEN '0-6 months (New)'
        WHEN tenure <= 12 THEN '7-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 36 THEN '25-36 months'
        ELSE '37+ months (Loyal)'
    END
ORDER BY 
    MIN(tenure);


-- ============================================================================
-- 2. CUSTOMER LIFETIME VALUE (CLV) ANALYSIS
-- ============================================================================

-- CLV by Churn Status
-- Business Question: How much revenue are we losing to churn?

WITH customer_clv AS (
    SELECT 
        customerID,
        Churn,
        tenure,
        MonthlyCharges,
        TotalCharges,
        -- Projected CLV assuming customers stay 3 more years (industry avg)
        CASE 
            WHEN Churn = 'No' THEN TotalCharges + (MonthlyCharges * 36)
            ELSE TotalCharges
        END AS projected_lifetime_value
    FROM telco_customer_churn
)
SELECT 
    Churn AS customer_status,
    COUNT(*) AS customer_count,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(TotalCharges), 2) AS avg_historical_revenue,
    ROUND(AVG(projected_lifetime_value), 2) AS avg_projected_clv,
    ROUND(SUM(TotalCharges), 2) AS total_revenue_to_date,
    ROUND(
        SUM(projected_lifetime_value - TotalCharges), 2
    ) AS potential_future_revenue
FROM customer_clv
GROUP BY Churn;


-- Revenue at Risk from High-Value Customers
-- Business Question: Which churning customers represent the biggest revenue loss?

SELECT 
    customerID,
    tenure,
    Contract,
    MonthlyCharges,
    TotalCharges,
    ROUND((MonthlyCharges * 12), 2) AS annual_revenue,
    CASE 
        WHEN MonthlyCharges >= 100 THEN 'High Value'
        WHEN MonthlyCharges >= 70 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_value_segment
FROM telco_customer_churn
WHERE Churn = 'Yes'
ORDER BY MonthlyCharges DESC
LIMIT 50;


-- ============================================================================
-- 3. CHURN DRIVERS ANALYSIS
-- ============================================================================

-- Churn by Contract Type
-- Business Question: Does contract length reduce churn?

SELECT 
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(tenure), 1) AS avg_tenure,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges
FROM telco_customer_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


-- Churn by Payment Method
-- Business Question: Do payment methods correlate with churn?

SELECT 
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges
FROM telco_customer_churn
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;


-- Churn by Internet Service Type
-- Business Question: Are fiber optic customers churning more?

SELECT 
    InternetService,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(tenure), 1) AS avg_tenure
FROM telco_customer_churn
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;


-- Churn by Service Bundles
-- Business Question: Do customers with more services churn less?

WITH service_count AS (
    SELECT 
        customerID,
        Churn,
        MonthlyCharges,
        tenure,
        (CASE WHEN PhoneService = 'Yes' THEN 1 ELSE 0 END +
         CASE WHEN InternetService != 'No' THEN 1 ELSE 0 END +
         CASE WHEN OnlineSecurity = 'Yes' THEN 1 ELSE 0 END +
         CASE WHEN OnlineBackup = 'Yes' THEN 1 ELSE 0 END +
         CASE WHEN DeviceProtection = 'Yes' THEN 1 ELSE 0 END +
         CASE WHEN TechSupport = 'Yes' THEN 1 ELSE 0 END +
         CASE WHEN StreamingTV = 'Yes' THEN 1 ELSE 0 END +
         CASE WHEN StreamingMovies = 'Yes' THEN 1 ELSE 0 END) AS services_count
    FROM telco_customer_churn
)
SELECT 
    services_count,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(tenure), 1) AS avg_tenure
FROM service_count
GROUP BY services_count
ORDER BY services_count;


-- ============================================================================
-- 4. DEMOGRAPHIC CHURN PATTERNS
-- ============================================================================

-- Churn by Demographics (Senior Citizens, Partners, Dependents)
-- Business Question: Which demographic segments are most at risk?

SELECT 
    CASE WHEN SeniorCitizen = 1 THEN 'Senior' ELSE 'Non-Senior' END AS age_group,
    Partner,
    Dependents,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges
FROM telco_customer_churn
GROUP BY 
    CASE WHEN SeniorCitizen = 1 THEN 'Senior' ELSE 'Non-Senior' END,
    Partner,
    Dependents
HAVING COUNT(*) >= 50  -- Filter for statistical significance
ORDER BY churn_rate_pct DESC;


-- Gender Analysis
-- Business Question: Is there a gender difference in churn?

SELECT 
    gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(tenure), 1) AS avg_tenure
FROM telco_customer_churn
GROUP BY gender;


-- ============================================================================
-- 5. COHORT ANALYSIS
-- ============================================================================

-- Tenure Cohorts: Retention by Time with Company
-- Business Question: How does retention change as customers age?

WITH tenure_cohorts AS (
    SELECT 
        CASE 
            WHEN tenure BETWEEN 1 AND 6 THEN '1-6 months'
            WHEN tenure BETWEEN 7 AND 12 THEN '7-12 months'
            WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
            WHEN tenure BETWEEN 25 AND 36 THEN '25-36 months'
            WHEN tenure BETWEEN 37 AND 48 THEN '37-48 months'
            WHEN tenure >= 49 THEN '49+ months'
        END AS cohort,
        COUNT(*) AS cohort_size,
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
        SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END) AS retained
    FROM telco_customer_churn
    GROUP BY cohort
)
SELECT 
    cohort,
    cohort_size,
    churned,
    retained,
    ROUND((churned / cohort_size * 100), 2) AS churn_rate_pct,
    ROUND((retained / cohort_size * 100), 2) AS retention_rate_pct
FROM tenure_cohorts
WHERE cohort IS NOT NULL
ORDER BY 
    CASE cohort
        WHEN '1-6 months' THEN 1
        WHEN '7-12 months' THEN 2
        WHEN '13-24 months' THEN 3
        WHEN '25-36 months' THEN 4
        WHEN '37-48 months' THEN 5
        WHEN '49+ months' THEN 6
    END;


-- ============================================================================
-- 6. HIGH-RISK CUSTOMER IDENTIFICATION
-- ============================================================================

-- Churn Risk Scoring Model (Rule-Based)
-- Business Question: Which current customers are most likely to churn?

WITH risk_scores AS (
    SELECT 
        customerID,
        tenure,
        Contract,
        MonthlyCharges,
        TotalCharges,
        PaymentMethod,
        InternetService,
        TechSupport,
        OnlineSecurity,
        Churn,
        -- Calculate risk score based on known churn drivers
        (CASE WHEN Contract = 'Month-to-month' THEN 3 ELSE 0 END +
         CASE WHEN tenure <= 12 THEN 3 ELSE 0 END +
         CASE WHEN PaymentMethod = 'Electronic check' THEN 2 ELSE 0 END +
         CASE WHEN TechSupport = 'No' THEN 2 ELSE 0 END +
         CASE WHEN OnlineSecurity = 'No' AND InternetService != 'No' THEN 2 ELSE 0 END +
         CASE WHEN MonthlyCharges > 80 THEN 2 ELSE 0 END +
         CASE WHEN InternetService = 'Fiber optic' THEN 1 ELSE 0 END) AS risk_score
    FROM telco_customer_churn
    WHERE Churn = 'No'  -- Only score active customers
)
SELECT 
    customerID,
    tenure,
    Contract,
    ROUND(MonthlyCharges, 2) AS monthly_charges,
    ROUND(TotalCharges, 2) AS total_charges,
    PaymentMethod,
    risk_score,
    CASE 
        WHEN risk_score >= 10 THEN 'Critical Risk'
        WHEN risk_score >= 7 THEN 'High Risk'
        WHEN risk_score >= 4 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM risk_scores
WHERE risk_score >= 7  -- Focus on high-risk customers
ORDER BY risk_score DESC, MonthlyCharges DESC;


-- High-Risk Customer Summary by Risk Category
-- Business Question: How many customers are in each risk tier?

WITH risk_scores AS (
    SELECT 
        customerID,
        MonthlyCharges,
        (CASE WHEN Contract = 'Month-to-month' THEN 3 ELSE 0 END +
         CASE WHEN tenure <= 12 THEN 3 ELSE 0 END +
         CASE WHEN PaymentMethod = 'Electronic check' THEN 2 ELSE 0 END +
         CASE WHEN TechSupport = 'No' THEN 2 ELSE 0 END +
         CASE WHEN OnlineSecurity = 'No' AND InternetService != 'No' THEN 2 ELSE 0 END +
         CASE WHEN MonthlyCharges > 80 THEN 2 ELSE 0 END +
         CASE WHEN InternetService = 'Fiber optic' THEN 1 ELSE 0 END) AS risk_score
    FROM telco_customer_churn
    WHERE Churn = 'No'
),
risk_categories AS (
    SELECT 
        customerID,
        MonthlyCharges,
        risk_score,
        CASE 
            WHEN risk_score >= 10 THEN 'Critical Risk'
            WHEN risk_score >= 7 THEN 'High Risk'
            WHEN risk_score >= 4 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_category
    FROM risk_scores
)
SELECT 
    risk_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(SUM(MonthlyCharges), 2) AS total_monthly_revenue_at_risk,
    ROUND(SUM(MonthlyCharges * 12), 2) AS annual_revenue_at_risk
FROM risk_categories
GROUP BY risk_category
ORDER BY 
    FIELD(risk_category, 'Critical Risk', 'High Risk', 'Medium Risk', 'Low Risk');


-- ============================================================================
-- 7. RETENTION OPPORTUNITY ANALYSIS
-- ============================================================================

-- Impact of Tech Support on Churn (for Internet Customers)
-- Business Question: Does tech support reduce churn?

SELECT 
    TechSupport,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges
FROM telco_customer_churn
WHERE InternetService != 'No'  -- Only internet customers can have tech support
GROUP BY TechSupport;


-- Contract Upgrade Opportunity
-- Business Question: What if we convert month-to-month to annual contracts?

WITH contract_comparison AS (
    SELECT 
        Contract,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
        ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
        ROUND(
            (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2
        ) AS churn_rate_pct
    FROM telco_customer_churn
    GROUP BY Contract
)
SELECT 
    Contract,
    total_customers,
    churned,
    avg_monthly_charges,
    churn_rate_pct,
    CASE Contract
        WHEN 'Month-to-month' THEN 
            ROUND((total_customers * avg_monthly_charges * 12 * (churn_rate_pct / 100)), 2)
        ELSE 0
    END AS potential_annual_revenue_saved
FROM contract_comparison
ORDER BY churn_rate_pct DESC;


-- ============================================================================
-- 8. FINANCIAL IMPACT OF CHURN
-- ============================================================================

-- Monthly Revenue Loss from Churn
-- Business Question: How much revenue are we losing each month to churn?

SELECT 
    SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END) AS monthly_revenue_lost,
    SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges * 12 ELSE 0 END) AS annual_revenue_lost,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS customers_churned,
    ROUND(AVG(CASE WHEN Churn = 'Yes' THEN MonthlyCharges END), 2) AS avg_monthly_charge_churned
FROM telco_customer_churn;


-- Break-Even Retention Investment
-- Business Question: How much can we spend to save a customer?

WITH churn_economics AS (
    SELECT 
        AVG(CASE WHEN Churn = 'Yes' THEN MonthlyCharges END) AS avg_churned_monthly,
        AVG(CASE WHEN Churn = 'Yes' THEN tenure END) AS avg_churned_tenure
    FROM telco_customer_churn
)
SELECT 
    ROUND(avg_churned_monthly, 2) AS avg_monthly_revenue_per_churned_customer,
    ROUND(avg_churned_tenure, 1) AS avg_tenure_at_churn_months,
    ROUND((avg_churned_monthly * 12), 2) AS annual_revenue_per_customer,
    -- Assuming 3-year CLV after retention
    ROUND((avg_churned_monthly * 36), 2) AS projected_3yr_clv_if_retained,
    -- Max retention cost = 20% of 1-year revenue (industry standard)
    ROUND((avg_churned_monthly * 12 * 0.20), 2) AS max_retention_spend_per_customer
FROM churn_economics;


/*
================================================================================
END OF SQL QUERIES (MySQL)
================================================================================
These queries provide comprehensive churn analysis suitable for:
1. Executive dashboards
2. Retention strategy development
3. Customer success interventions
4. Revenue forecasting

Key MySQL-specific changes from PostgreSQL:
- Removed ::numeric casting (MySQL handles implicit conversion)
- Used FIELD() function for custom ORDER BY instead of CASE
- All other syntax is compatible with MySQL 8.0+

Interview Preparation Tips:
- Explain the business logic for risk scoring
- Discuss statistical significance (sample sizes in GROUP BY)
- Walk through cohort analysis interpretation
- Quantify financial impact of retention initiatives
================================================================================
*/
