# Assessment_Q4.sql
# Where needed, 'u', 's' and 'p' were used as aliases for users_customuser, savings_savingsaccount and plans_plan tables respectively for easy querying.

SELECT
    u.id AS customer_id,
# I used the concat function below to combine the first_name and last_name columns as name. 
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(s.id) AS total_transactions,
# Round the estimated CLV to 2 decimal places.
# Multiply the average confirmed amount by 0.1%.
    ROUND((COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * (0.001 * AVG(s.confirmed_amount)), 2) AS estimated_clv
FROM
    users_customuser AS u
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
