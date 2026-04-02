# ----------------------------------------------------
# 1. DATABASE SETUP
# ----------------------------------------------------
CREATE DATABASE IF NOT EXISTS bankdb;
USE bankdb;


SET FOREIGN_KEY_CHECKS = 0;


drop table customer;

# ----------------------------------------------------
# 2. CREATE TABLES 
# ----------------------------------------------------

CREATE TABLE customer (
    customer_id         VARCHAR(10) PRIMARY KEY,
    age                 INT NULL,
    job                 VARCHAR(50) NULL,
    marital             VARCHAR(20) NULL,
    education           VARCHAR(50) NULL,
    demographic_balance DECIMAL(18,6) NULL, 
    housing_loan        TINYINT NULL,
    personal_loan       TINYINT NULL,
    cc_balance          DECIMAL(18,6) NULL,  
    credit_limit        DECIMAL(18,6) NULL,
    purchases           DECIMAL(18,6) NULL, 
    payments            DECIMAL(18,6) NULL  
);

CREATE TABLE account (
    account_id    VARCHAR(20) PRIMARY KEY,
    customer_id   VARCHAR(10),
    account_type ENUM('checking','savings','credit'),
    open_date     DATE,
    
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE loan (
    loan_id       VARCHAR(20) PRIMARY KEY,
    customer_id   VARCHAR(10),
    loan_type     ENUM('housing','personal'),
    loan_amount   DECIMAL(12,2),
    start_date    DATE,
    status        ENUM('active','closed'),
    
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);


CREATE TABLE transaction_table (
    transaction_id  BIGINT PRIMARY KEY,
    customer_id     VARCHAR(10),
    account_id      VARCHAR(20),
    transaction_ts  DATETIME,
    amount          DECIMAL(12,2),
    category        VARCHAR(30),
    is_fraud        TINYINT,

    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

# ----------------------------------------------------
# 3. LOAD DATA 
# ----------------------------------------------------

-- 3-1. customer.csv 
LOAD DATA LOCAL INFILE '/Users/wonny/Library/CloudStorage/OneDrive-Emory/1. Emory/1. Material/1. MSBA/ISOM-671-4101_Managing Big Data/3. Assignment/Group Project/3. Due 1205/2. Dataset/customer.csv'
INTO TABLE customer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    customer_id,
    @age,
    job,
    marital,
    education,
    @demographic_balance,
    @housing_loan,
    @personal_loan,
    @cc_balance,
    @credit_limit,
    @purchases,
    @payments
)
SET
    --
    age = NULLIF(TRIM(@age), ''),
    demographic_balance = NULLIF(TRIM(@demographic_balance), ''),
    housing_loan = NULLIF(TRIM(@housing_loan), ''),
    personal_loan = NULLIF(TRIM(@personal_loan), ''),
    cc_balance = NULLIF(TRIM(@cc_balance), ''),
    credit_limit = NULLIF(TRIM(@credit_limit), ''),
    purchases = NULLIF(TRIM(@purchases), ''),
    payments = NULLIF(TRIM(@payments), '');


-- 3-2. account.csv 
LOAD DATA LOCAL INFILE '/Users/wonny/Library/CloudStorage/OneDrive-Emory/1. Emory/1. Material/1. MSBA/ISOM-671-4101_Managing Big Data/3. Assignment/Group Project/3. Due 1205/2. Dataset/account.csv'
INTO TABLE account
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(account_id, customer_id, account_type, open_date);


-- 3-3. loan.csv 
LOAD DATA LOCAL INFILE '/Users/wonny/Library/CloudStorage/OneDrive-Emory/1. Emory/1. Material/1. MSBA/ISOM-671-4101_Managing Big Data/3. Assignment/Group Project/3. Due 1205/2. Dataset/loan.csv'
INTO TABLE loan
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(loan_id, customer_id, loan_type, loan_amount, start_date, status);


-- 3-4. transaction.csv 
LOAD DATA LOCAL INFILE '/Users/wonny/Library/CloudStorage/OneDrive-Emory/1. Emory/1. Material/1. MSBA/ISOM-671-4101_Managing Big Data/3. Assignment/Group Project/3. Due 1205/2. Dataset/transaction.csv'
INTO TABLE transaction_table
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transaction_id, customer_id, account_id, transaction_ts, amount, category, is_fraud);


# ----------------------------------------------------
# 4. FINISH 
# ----------------------------------------------------
SET FOREIGN_KEY_CHECKS = 1;



SELECT 
    (SELECT COUNT(*) FROM customer) AS customer_rows,
    (SELECT COUNT(*) FROM account) AS account_rows,
    (SELECT COUNT(*) FROM loan) AS loan_rows,
    (SELECT COUNT(*) FROM transaction_table) AS transaction_rows;


SELECT *
FROM account a
LEFT JOIN customer c ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT *
FROM loan l
LEFT JOIN customer c ON l.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



SELECT *
FROM transaction_table t
LEFT JOIN customer c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL
LIMIT 20;

SELECT *
FROM transaction_table t
LEFT JOIN account a ON t.account_id = a.account_id
WHERE a.account_id IS NULL
LIMIT 20;



SELECT 
    SUM(cc_balance IS NULL) AS null_cc_balance,
    SUM(credit_limit IS NULL) AS null_credit_limit,
    SUM(purchases IS NULL) AS null_purchases,
    SUM(payments IS NULL) AS null_payments
FROM customer;


SELECT 
    c.customer_id,
    a.account_id,
    t.transaction_id,
    t.amount,
    t.category
FROM customer c
JOIN account a ON c.customer_id = a.customer_id
JOIN transaction_table t ON a.account_id = t.account_id
LIMIT 20;

SELECT 
    COUNT(*) AS total_tx,
    SUM(is_fraud) AS fraud_tx,
    ROUND(AVG(is_fraud), 4) AS fraud_ratio
FROM transaction_table;


select count(1) from customer;
select count(1) from account;
select count(1) from loan;
select count(1) from transaction_table;


SELECT COUNT(*) 
FROM transaction_table t 
LEFT JOIN account a ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


SELECT is_fraud, COUNT(*) 
FROM transaction_table 
GROUP BY is_fraud;

SELECT customer_id, COUNT(*) 
FROM customer GROUP BY customer_id HAVING COUNT(*) > 1;
