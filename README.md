# Bank Transaction Analysis & Anomaly Detection
## Objective
This project analyses a public bank transaction dataset with Python. The goal is to understand normal transaction behaviour, look for unusual patterns and identify potentially suspicious transactions using simple statistical methods and business rules.
## Dataset
The project uses the [Bank Transaction EDA for Fraud Detection](https://www.kaggle.com/code/mllion/bank-transaction-eda-for-fraud-detection/input) from Kaggle. It contains 2,512 transactions from 495 accounts, recorded between 2 January 2023 and 1 January 2024. There are 16 columns in total. The dataset does not have a fraud label, so it is not possible to confirm whether a transaction is actually fraudulent. The analysis only identifies transactions that may need further investigation. The dataset file is not included in this repository. To run the notebook, download bank_transactions_data_2.csv from Kaggle and place it next to the notebook.
## Tools
Python, Pandas, Matplotlib, Seaborn, Jupyter Notebook
## Analysis
Data check, normal amounts and activity per account, accounts with unusually high activity, time patterns and bursts, channels and transaction types, variables useful for detecting unusual behaviour, and three simple rules that flag suspicious transactions.
## Key Findings
1. The median transaction amount is 211.14, and a typical account made 5 transactions during the year.
2. Four accounts made 12 transactions each. AC00460 and AC00363 are also among the top 10 accounts by both transaction count and total transaction amount.
3. All transactions took place within three hours of the day (16, 17 and 18). I also checked for transaction bursts, but no account made more than two transactions on the same day.
4. Channels and transaction types have similar median amounts (204.16 to 218.96 across channels). Only 122 transactions (about 4.9%) have multiple login attempts. These transactions took longer (median 127.5 vs 111.0 seconds), but their amounts were similar.
5. Three simple rules flagged 330 transactions in total. Fourteen transactions triggered two rules, making them the main candidates for further review.
## Limitations
- The dataset has no fraud labels, so it is not possible to confirm whether flagged transactions are actually fraudulent or measure how accurately the rules detect fraud.
- PreviousTransactionDate is later than TransactionDate in all rows,  so this column was excluded.
- All transactions occurred between 16:00 and 19:00, which limits the usefulness of time-based analysis.
- Each account made only about 5 transactions per year on average, so there is limited activity to establish normal behaviour for individual accounts.
SQL Version
The same dataset was also analysed with SQL (SQLite): bank-transactions-sql-analysis. Both versions cover the same questions, and the SQL results match the results from this notebook.
