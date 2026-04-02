==================================================
Emory MSBA – ISOM 671 Group Project (Part 1)
README: Setup & Load Instructions
==================================================

This document explains how to reproduce the database setup, load the cleaned datasets, 
and understand the project folder structure.

--------------------------------------------------
1. Folder Structure
--------------------------------------------------

Part1/
 ├── 01_DataCleaning/
 │       ├── customer.csv
 │       ├── account.csv
 │       ├── loan.csv
 │       └── transaction.csv
 │
 ├── 02_MySQL_Schema_ERD/
 │       ├── MySQL_schema.sql
 │       └── ERD.png
 │
 ├── 03_DataDictionary/
 │       └── data_dictionary.xlsx
 │
 └── 04_README_LoadInstructions/
         └── README.txt   (this file)


--------------------------------------------------
2. Requirements
--------------------------------------------------
- MySQL Server 8.0+
- MySQL Workbench or CLI
- LOCAL INFILE enabled:
    SET GLOBAL local_infile = 1;

- Place all CSV files in the absolute paths referenced inside the SQL script
  OR modify the paths inside the SQL file.


--------------------------------------------------
3. How to Create the Database
--------------------------------------------------

1. Open MySQL Workbench.
2. Open the file:
      Part1/02_MySQL_Schema_ERD/MySQL_schema.sql
3. Run the entire script.

The script will:
- Create the database 'bankdb'
- Create all necessary tables (customer, account, loan, transaction_table)
- Load all cleaned CSVs
- Re-enable foreign key checks


--------------------------------------------------
4. Load Order (automatically handled in SQL script)
--------------------------------------------------
The SQL script loads data in the correct dependency order:

(1) customer  
(2) account  
(3) loan  
(4) transaction_table  

This order ensures all foreign key constraints are satisfied.


--------------------------------------------------
5. CSV Cleaning Notes
--------------------------------------------------
The cleaned CSVs located in:
    /Part1/01_DataCleaning/

Cleaning rules applied:
- Empty strings converted to NULL
- Numeric fields standardized to valid decimal formats
- Date fields validated to YYYY-MM-DD
- No orphan account_id or customer_id
- Consistent categorical values enforced


--------------------------------------------------
6. ERD Location
--------------------------------------------------
The ERD diagram used for schema validation is stored in:
    /Part1/02_MySQL_Schema_ERD/ERD.png


--------------------------------------------------
7. Data Dictionary
--------------------------------------------------
A full description of all tables, columns, data types, and meanings is found here:
    /Part1/03_DataDictionary/data_dictionary.xlsx


--------------------------------------------------
8. Contact & Collaboration Notes
--------------------------------------------------
This project was completed collaboratively using a shared OneDrive folder.
Each teammate contributed to data cleaning, schema creation, documentation,
and validation.

--------------------------------------------------
End of README
--------------------------------------------------
