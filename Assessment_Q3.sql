# Assessment_Q3.sql

SELECT
    p.id AS plan_id,
    p.owner_id,
# Use CASE below to determine the plan type.
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
		DATE(MAX(s.transaction_date)) AS last_transaction_date, 
# Calculate the days since the last transaction.
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days 		
FROM
    plans_plan p
JOIN
    savings_savingsaccount s ON p.id = s.plan_id	# Use JOIN to join savings_savingsaccount table  on plan_id.
WHERE
    p.is_regular_savings = 1 OR p.is_a_fund = 1
GROUP BY
    p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
HAVING
    MAX(s.transaction_date) < CURDATE() - INTERVAL 1 YEAR;
