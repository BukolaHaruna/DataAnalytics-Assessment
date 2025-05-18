# DataAnalytics-Assessment
This repository contains the SQL solutions to Cowrywise Data Analyst Assessment.

## Overview
It shows my ability to write SQL queries to solve business problems using the provided database. The solutions demonstrate proficiency in data retrieval, aggregation, joins, and data manipulation across the `users_customuser`, `savings_savingsaccount`, `plans_plan`, and `withdrawals_withdrawal` tables.

## Per-Question Explanations

### Question 1: High-Value Customers with Multiple Products

**Objective:** Identify customers with at least one funded savings plan and one funded investment plan, and sort by total deposits.

**Tables:** `users_customuser`, `savings_savingsaccount`, and `plans_plan`

**My Approach:**

1.  **Joined tables:** Joined `users_customuser` with `savings_savingsaccount` on `u.id = s.owner_id` (`owner_id` is a foreign key to `users_customuser.id`). Joined `savings_savingsaccount` with `plans_plan` on `s.plan_id = p.id` (as `plan_id` is a foreign key to `plans_plan.id`) to combine customer information with their account and plan details. This allowed me to access data from all three tables in a single query.
2.  **Filtered funded transactions:** Filtered for transactions using where `s.confirmed_amount > 0` (`confirmed_amount` represents the value of inflow) to include only deposits.
3.  **Counted distinct plan types:** Used `COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id ELSE NULL END)` to count distinct savings plans and `COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END)` to count distinct investment plans. `COUNT(DISTINCT)` ensures each plan is counted only once, even if a customer has multiple transactions within the same plan. The `CASE WHEN` statements conditionally count plans based on their type.
4.  **Grouped by customer:** Grouped the results by `u.id` and `CONCAT(u.first_name, ' ', u.last_name)` as `u.name` to aggregate data and calculate totals for each customer.
5.  **Filtered for customers with both plan types:** Applied a `HAVING` clause with the same `COUNT(DISTINCT CASE WHEN ...)` conditions, but using `>= 1`. This ensures that only customers who have at least one savings plan AND at least one investment plan are included in the result.
6.  **Calculated total deposits:** Calculated `total_deposits` by `SUM(s.confirmed_amount) / 100.00` to convert from Kobo to Naira. The result was then rounded to two decimal places for proper formatting.
7.  **Ordered by deposits:** Ordered the final result by `total_deposits DESC` to display the depositing customers in descending order.

### Question 2: Transaction Frequency Analysis

**Objective:** Calculate the average number of transactions per customer per month and categorise them into "High Frequency" (≥10 transactions/month), "Medium Frequency" (3-9 transactions/month), and "Low Frequency" (≤2 transactions/month).

**Tables:** `users_customuser` and `savings_savingsaccount`

**My Approach:**

1.  **Created MonthlyTransactions CTE:** Created a Common Table Expression (CTE) named `MonthlyTransactions` to determine the number of transactions per customer for each month. This was achieved by grouping `savings_savingsaccount` (s) by `s.owner_id` and `DATE_FORMAT(s.transaction_date, '%Y-%m')` and using `COUNT(*)` to get the total `monthly_transactions` for each customer-month combination.
2.  **Created AvgTransactions CTE:** Created another CTE named `AvgTransactions` to calculate the average number of monthly transactions per customer. This CTE used the results from `MonthlyTransactions`, grouped by `owner_id`, and calculated the average of `monthly_transactions` using `AVG()`.
3.  **Categorised customers:** In the final `SELECT` statement, used a `CASE` statement to categorise customers into "High Frequency," "Medium Frequency," and "Low Frequency" based on their `avg_transactions_per_month`. The conditions were: `>= 10` for "High," between `3` and `9` for "Medium," and `<= 2` for "Low."
4.  **Counted customers per category:** Counted the number of customers in each frequency category using `COUNT(*)`.
5.  **Calculated average transactions per category:** Calculated the average `avg_transactions_per_month` for each frequency category using `AVG()` and rounded the result to one decimal place using `ROUND()` to match the expected output format.
6.  **Grouped by category:** Grouped the results by `frequency_category` to get the final aggregated output.

### Question 3: Account Inactivity Alert

**Objective:** Find all active accounts (savings or investments) with no transactions in the last one year (365 days).

**Tables:** `plans_plan` and `savings_savingsaccount`

**My Approach:**

1.  **Joined tables:** Joined `plans_plan` (p) and `savings_savingsaccount` (s) on `p.id = s.plan_id` to link plans to their transaction history.
2.  **Filtered active accounts:** Filtered for active savings plans (`p.is_regular_savings = 1`) or active investment plans (`p.is_a_fund = 1`) using a `WHERE` clause with an `OR` condition.
3.  **Found last transaction date:** Used `MAX(s.transaction_date)` to find the most recent transaction date for each plan.
4.  **Calculated inactivity days:** Calculated the number of days since the last transaction using `DATEDIFF(CURDATE(), MAX(s.transaction_date))`, where `CURDATE()` gets the current date.
5.  **Extracted date only:** Extracted only the date part of the last transaction using `DATE(MAX(s.transaction_date))` to match the expected output format, which does not include the timestamp.
6.  **Grouped by plan details:** Grouped the results by `p.id`, `p.owner_id`, `p.is_regular_savings`, and `p.is_a_fund` to get the correct aggregation for each plan.
7.  **Filtered for inactive accounts:** Used a `HAVING` clause to filter for accounts where the `MAX(s.transaction_date)` is less than `CURDATE() - INTERVAL 1 YEAR`. This condition identifies accounts with no transactions in the past year.

### Question 4: Customer Lifetime Value (CLV) Estimation

**Objective:** For each customer, calculate account tenure (months since signup), total transactions, and estimated CLV (assuming profit per transaction is 0.1% of the transaction value). Ordered by estimated CLV from highest to lowest.

**Tables:** `users_customuser` and `savings_savingsaccount`

**My Approach:**

1.  **Joined tables:** Joined `users_customuser` (u) and `savings_savingsaccount` (s) on `u.id = s.owner_id` to link customer information with their transaction data.
2.  **Calculated tenure:** Calculated `tenure_months` using `TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())` to find the difference in months between the customer's `date_joined` and the current date.
3.  **Counted transactions:** Counted the `total_transactions` for each customer using `COUNT(s.id)`.
4.  **Calculated CLV:** Calculated the `estimated_clv` using the provided formula: `(COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * (0.001 * AVG(s.confirmed_amount))`.
    * `COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())` represents the average number of transactions per month.
    * Multiplying by `12` shows the transactions annually.
    * `0.001` represents the 0.1% profit per transaction.
    * `AVG(s.confirmed_amount)` calculates the average transaction value (in Kobo).
5.  **Rounded CLV:** Rounded the `estimated_clv` to two decimal places using `ROUND()` to match the expected output format.
6.  **Grouped by customer:** Grouped the results by `u.id`, `u.first_name`, `u.last_name`, and `u.date_joined` to calculate the CLV for each individual customer.
7.  **Ordered by CLV:** Ordered the results by `estimated_clv` in descending order to display the customers with the highest CLV first.

## Challenges

* The primary challenge was to accurately show the relationships between tables and the specific data manipulations required.
* For Question 1 - Ensuring the accurate counting of distinct savings and investment plans using `COUNT(DISTINCT CASE WHEN ...)` was crucial to avoid potential overcounting.
* For Question 2 - The correct use of CTEs to break down the query into logical steps was essential for better readability.
* For Question 3 - Formatting the `last_transaction_date` using the `DATE()` function to match the expected output format (without the timestamp) was a specific requirement.
* For Question 4 - Accurately applying the CLV formula and correctly interpreting the units of the `confirmed_amount` (kobo) were important.
