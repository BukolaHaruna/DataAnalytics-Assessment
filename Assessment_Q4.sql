# Assessment_Q4.sql

SELECT
    u.id AS customer_id,
# I used the concat function below to combine the first_name and last_name columns as name. 
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(s.id) AS total_transactions,
# I multiplied the average confirmed amount by 0.1% and rounded the estimated CLV to 2 decimal places.
    ROUND((COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * (0.001 * AVG(s.confirmed_amount)), 2) AS estimated_clv
FROM
    users_customuser AS u
# Made use of Join to combine the savings_savingsaccount table on the owner_ID.
JOIN
    savings_savingsaccount s ON u.id = s.owner_id
GROUP BY
    u.id,
    u.first_name,
    u.last_name,
    u.date_joined
ORDER BY
    estimated_clv DESC;
