# Assessment_Q2.sql
    
# CTE to calculate the number of transactions per customer for each month.
WITH MonthlyTransactions AS (
    SELECT
        s.owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS transaction_month, # To specifically extract the year and month from transaction date.
        COUNT(*) AS monthly_transactions
    FROM
        savings_savingsaccount AS s
    GROUP BY
        s.owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m')
),
    
# Calculate the average number of transactions per month for each customer.
AvgTransactions AS (
    SELECT
        owner_id,
        AVG(monthly_transactions) AS avg_transactions_per_month
    FROM
        MonthlyTransactions
    GROUP BY
        owner_id
)
    
# Main query to categorise customers based on their average monthly transaction frequency.
SELECT
    CASE
        WHEN at.avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN at.avg_transactions_per_month >= 3 AND at.avg_transactions_per_month <= 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    
# Using the ROUND function to round the avg_transactions_per_category to 1 decimal place to match the expected output.
    ROUND(AVG(at.avg_transactions_per_month), 1) AS avg_transactions_per_category
FROM
    AvgTransactions AS at
GROUP BY
    frequency_category;
