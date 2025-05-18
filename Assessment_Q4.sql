# Assessment_Q4.sql
# Objective: Calculate Customer Lifetime Value (CLV) for each customer assuming the profit_per_transaction is 0.1% of the transaction value.
# Tables used: "users_customuser" and "savings_savingsaccount"
# Where needed, 'u', 's' and 'p' were used as aliases for users_customuser, savings_savingsaccount and plans_plan tables respectively for easy querying.

SELECT
    u.id AS customer_id,
# The CONCAT function below combines the first_name and last_name columns from the users_customuser table as name. 
# The ' ' in the middle adds a space between the first and last names.
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months, 	# Calculate customer tenure in months
    COUNT(s.id) AS total_transactions,
# Round the estimated CLV to 2 decimal places.
# Multiply the average confirmed_amount (profit per transaction) by 0.1% (0.001).
    ROUND((COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * (0.001 * AVG(s.confirmed_amount)), 2) AS estimated_clv
FROM
    users_customuser u
# Join the savings_savingsaccount table on the owner_ID.
JOIN
    savings_savingsaccount s ON u.id = s.owner_id
GROUP BY
    u.id,
    u.first_name,
    u.last_name,
    u.date_joined
ORDER BY
    estimated_clv DESC;