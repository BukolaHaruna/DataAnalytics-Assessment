# Assessment_Q1.sql
# Objective: To find customers with at least one funded savings plan and one funded investment plan, sorted by total deposits.
# Tables used: "users_customuser", "savings_savingsaccount" and "plans_plan".

SELECT
    u.id AS owner_id,               # Renamed to give the expected output for column name.
# The CONCAT function below combines the first_name and last_name columns from the users_customuser table as name. 
# The ' ' in the middle adds a space between the first and last names.
    CONCAT(u.first_name, ' ', u.last_name) AS name, 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id ELSE NULL END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END) AS investment_count,
# Since 100kobo = 1naira, to convert the amounts in kobo to naira, we divide the amounts by 100.
# The syntax ROUND provides the total_deposits output to 2 decimal places.
    ROUND((SUM(s.confirmed_amount) / 100), 2) AS total_deposits 
# Below, 'u', 's' and 'p' were used as aliases for users_customuser, savings_savingsaccount and plans_plan tables respectively for easy querying.
FROM
    users_customuser as u      
JOIN
    savings_savingsaccount as s ON u.id = s.owner_id
JOIN
    plans_plan as p ON s.plan_id = p.id
WHERE s.confirmed_amount > 0
# GROUPING BY customer name and id to count plans and sum deposits.
GROUP BY
    u.id, u.name                  
# Using the HAVING clause to accurately filter for users who have at least one of each plan type.
HAVING
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id ELSE NULL END) >= 1
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END) >= 1
# Sort by total deposits as requested.
ORDER BY
    total_deposits DESC;          