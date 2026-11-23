-- Bank Transaction Analysis with SQL (SQLite)
-- The same dataset was also analysed with Python.
-- Values marked "Python check" come from that Python analysis and are used to validate the SQL results.
-- The dataset has no fraud label, so results show unusual activity, not confirmed fraud.

-- SETUP: CHECK THE IMPORT AND CREATE A CLEAN TABLE
-- 0.1 Are the numbers stored as numbers?
SELECT typeof(TransactionAmount) AS amount_type,
       typeof(LoginAttempts) AS login_attempts_type,
       COUNT(*) AS rows_count
FROM transactions
GROUP BY 1, 2;

-- 0.2 Create a clean copy of the table without IP addresses and device IDs
DROP TABLE IF EXISTS clean_transactions;

CREATE TABLE clean_transactions AS
SELECT TransactionID, AccountID,
       CAST(TransactionAmount AS REAL) AS TransactionAmount,
       TransactionDate, TransactionType, Location, MerchantID, Channel,
       CAST(CustomerAge AS INTEGER) AS CustomerAge,
       CustomerOccupation,
       CAST(TransactionDuration AS INTEGER) AS TransactionDuration,
       CAST(LoginAttempts AS INTEGER) AS LoginAttempts,
       CAST(AccountBalance AS REAL) AS AccountBalance
FROM transactions;

-- 0.3 Check the number of rows
SELECT COUNT(*) AS rows_count FROM clean_transactions;

-- QUESTION 1. What is a normal transaction amount and frequency?
-- 1.1. Number of transactions, accounts and period covered
SELECT COUNT(*) AS total_transactions,
       COUNT(DISTINCT AccountID) AS total_accounts,
       MIN(TransactionDate) AS first_transaction,
       MAX(TransactionDate) AS last_transaction
FROM clean_transactions;

-- 1.2. Total, average, min and max amount
SELECT ROUND(SUM(TransactionAmount), 2) AS total_amount,
       ROUND(AVG(TransactionAmount), 2) AS average_amount,
       MIN(TransactionAmount) AS min_amount,
       MAX(TransactionAmount) AS max_amount
FROM clean_transactions;

-- 1.3. How many transactions fall into each amount group
SELECT CASE WHEN TransactionAmount < 100 THEN '1. Under 100'
            WHEN TransactionAmount < 500 THEN '2. 100-499'
            WHEN TransactionAmount < 1000 THEN '3. 500-999'
            ELSE '4. 1000 and above' END AS amount_group,
       COUNT(*) AS transactions
FROM clean_transactions
GROUP BY amount_group
ORDER BY amount_group;

-- 1.4. Transactions and average amount by channel
SELECT ROUND(1.0 * COUNT(*) / COUNT(DISTINCT AccountID), 2) AS avg_transactions_per_account
FROM clean_transactions;

-- QUESTION 2. Which accounts have unusually high activity?
-- 2.1. Accounts with the most transactions
SELECT AccountID,
       COUNT(*) AS transactions,
       ROUND(SUM(TransactionAmount), 2) AS total_amount
FROM clean_transactions
GROUP BY AccountID
ORDER BY transactions DESC, total_amount DESC
LIMIT 10;

-- 2.2. Accounts with the largest total amount
SELECT AccountID,
       COUNT(*) AS transactions,
       ROUND(SUM(TransactionAmount), 2) AS total_amount
FROM clean_transactions
GROUP BY AccountID
ORDER BY total_amount DESC
LIMIT 10;

-- 2.3. Accounts with 10 or more transactions
SELECT AccountID, COUNT(*) AS transactions
FROM clean_transactions
GROUP BY AccountID
HAVING COUNT(*) >= 10
ORDER BY transactions DESC;

-- QUESTION 3. Are there transaction bursts within short periods?
-- 3.1 Accounts with 2 or more transactions on the same day
SELECT AccountID,
       DATE(TransactionDate) AS day,
       COUNT(*) AS transactions
FROM clean_transactions
GROUP BY AccountID, DATE(TransactionDate)
HAVING COUNT(*) >= 2
ORDER BY transactions DESC;

-- QUESTION 4. Are particular times or categories unusual?
-- 4.1. Transactions by month
SELECT strftime('%Y-%m', TransactionDate) AS month,
       COUNT(*) AS transactions
FROM clean_transactions
GROUP BY month
ORDER BY month;

-- 4.2. Transactions by hour of the day
SELECT strftime('%H', TransactionDate) AS hour_of_day,
       COUNT(*) AS transactions
FROM clean_transactions
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 4.3 Transactions and average amount by channel
SELECT Channel,
       COUNT(*) AS transactions,
       ROUND(AVG(TransactionAmount), 2) AS average_amount
FROM clean_transactions
GROUP BY Channel
ORDER BY transactions DESC;

-- 4.4 Debit vs credit transactions
SELECT TransactionType,
       COUNT(*) AS transactions,
       ROUND(AVG(TransactionAmount), 2) AS average_amount
FROM clean_transactions
GROUP BY TransactionType
ORDER BY transactions DESC;

-- QUESTION 5. Which variables could be useful for detecting unusual behaviour?
-- 5.1. Number of large transactions (above the top 5% threshold from Python)
SELECT COUNT(*) AS large_transactions
FROM clean_transactions
WHERE TransactionAmount > 878.18;

-- 5.2. The 10 largest transactions
SELECT TransactionID, AccountID, TransactionAmount, Channel, LoginAttempts
FROM clean_transactions
ORDER BY TransactionAmount DESC
LIMIT 10;

-- 5.3. Do transactions with more login attempts look different?
SELECT LoginAttempts,
       COUNT(*) AS transactions,
       ROUND(AVG(TransactionAmount), 2) AS average_amount,
       ROUND(AVG(TransactionDuration), 1) AS average_duration
FROM clean_transactions
GROUP BY LoginAttempts
ORDER BY LoginAttempts;

-- QUESTION 6. Can simple rules flag suspicious transactions?
-- 6.1. How many transactions trigger each rule
SELECT SUM(LoginAttempts >= 3) AS rule1_logins,
       SUM(TransactionAmount > 878.18) AS rule2_big_amount,
       SUM(TransactionDuration > 265) AS rule3_long_duration
FROM clean_transactions;

-- 6.2. How many rules each transaction triggers
SELECT (LoginAttempts >= 3) + (TransactionAmount > 878.18) + (TransactionDuration > 265) AS rules_triggered,
       COUNT(*) AS transactions
FROM clean_transactions
GROUP BY rules_triggered
ORDER BY rules_triggered;

-- 6.3. The most suspicious transactions (2 or more rules)
SELECT TransactionID, AccountID, TransactionAmount, TransactionDuration, LoginAttempts
FROM clean_transactions
WHERE (LoginAttempts >= 3) + (TransactionAmount > 878.18) + (TransactionDuration > 265) >= 2
ORDER BY TransactionAmount DESC;
