# Assessment_Q1.sql
    
SELECT
    u.id AS owner_id,               
# The CONCAT function below combines the first_name and last_name columns from the users_customuser table as name.
    CONCAT(u.first_name, ' ', u.last_name) AS name, 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id ELSE NULL END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END) AS investment_count,
# 100kobo = 1naira, to convert the amounts in kobo to naira, we divide the amounts by 100 and round to 2 decimal places.
    ROUND((SUM(s.confirmed_amount) / 100), 2) AS total_deposits 
FROM
    users_customuser as u      
JOIN
    savings_savingsaccount as s ON u.id = s.owner_id
JOIN
    plans_plan as p ON s.plan_id = p.id
WHERE s.confirmed_amount > 0
GROUP BY
    u.id, u.name                  
# Using the HAVING clause to filter for users who have at least one of each plan type.
HAVING
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id ELSE NULL END) >= 1
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END) >= 1
# Sort by total deposits.
ORDER BY
    total_deposits DESC;          
