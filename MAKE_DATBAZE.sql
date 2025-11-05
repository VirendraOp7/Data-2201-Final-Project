
-- DATA2201 Group Project - Group G
-- Group Members: Virendra Gadhavi, Mo Jarret, Mahekdeep Kaur
-- Database Creation Script for SKS National Bank

-- Delete the database if it already exists
USE master;
GO

IF EXISTS(SELECT name FROM sys.databases WHERE name = 'SKS_National_Bank')
    DROP DATABASE SKS_National_Bank;
GO

-- Create the database
CREATE DATABASE SKS_National_Bank;
GO

-- Use the database
USE SKS_National_Bank;
GO

-- Create Branch table
CREATE TABLE Branch (
    branch_id INT PRIMARY KEY IDENTITY(1,1),
    branch_name VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(100) NOT NULL,
    branch_address VARCHAR(255) NOT NULL,
    total_deposits DECIMAL(15,2) DEFAULT 0.00,
    total_loans DECIMAL(15,2) DEFAULT 0.00
);
GO

-- Create Employee table first (needed for Customer foreign key)
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    employee_home_address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(25) NOT NULL,
    start_date DATE NOT NULL,
    manager_id INT NULL,
    CONSTRAINT FK_Employee_Manager FOREIGN KEY (manager_id) REFERENCES Employee(employee_id)
);
GO

-- Create Customer table
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    customer_home_address VARCHAR(255) NOT NULL,
    city VARCHAR(25) NOT NULL,
    country VARCHAR(25) NOT NULL,
    postal_code VARCHAR(6) NOT NULL,
    personal_banker_id INT NULL,
    CONSTRAINT FK_Customer_PersonalBanker FOREIGN KEY (personal_banker_id) REFERENCES Employee(employee_id),
    CONSTRAINT CHK_PostalCode_Length CHECK (LEN(postal_code) = 6)
);
GO

-- Create Location table
CREATE TABLE Location (
    location_id INT PRIMARY KEY IDENTITY(1,1),
    location_name VARCHAR(100) NOT NULL,
    location_type VARCHAR(50) NOT NULL,
    branch_id INT NULL,
    CONSTRAINT FK_Location_Branch FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    CONSTRAINT CHK_LocationType CHECK (location_type IN ('Branch', 'Office'))
);
GO

-- Create EmployeeLocation junction table
CREATE TABLE EmployeeLocation (
    employee_id INT NOT NULL,
    location_id INT NOT NULL,
    CONSTRAINT PK_EmployeeLocation PRIMARY KEY (employee_id, location_id),
    CONSTRAINT FK_EmployeeLocation_Employee FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    CONSTRAINT FK_EmployeeLocation_Location FOREIGN KEY (location_id) REFERENCES Location(location_id)
);
GO

-- Create Account table
CREATE TABLE Account (
    account_id INT PRIMARY KEY IDENTITY(1,1),
    branch_id INT NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    last_accessed DATE NOT NULL,
    interest_rate DECIMAL(5,2) NULL,
    CONSTRAINT FK_Account_Branch FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    CONSTRAINT CHK_AccountType CHECK (account_type IN ('Savings', 'Chequing'))
);
GO

-- Add check constraint for interest rate separately
ALTER TABLE Account
ADD CONSTRAINT CHK_InterestRate 
CHECK (
    (account_type = 'Savings' AND interest_rate IS NOT NULL) OR
    (account_type = 'Chequing' AND interest_rate IS NULL)
);
GO

-- Create ChequingOverdraft table
CREATE TABLE ChequingOverdraft (
    overdraft_id INT PRIMARY KEY IDENTITY(1,1),
    account_id INT NOT NULL,
    check_number VARCHAR(20) NOT NULL,
    overdraft_date DATE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    CONSTRAINT FK_ChequingOverdraft_Account FOREIGN KEY (account_id) REFERENCES Account(account_id)
);
GO

-- Create AccountHolder junction table
CREATE TABLE AccountHolder (
    account_id INT NOT NULL,
    customer_id INT NOT NULL,
    CONSTRAINT PK_AccountHolder PRIMARY KEY (account_id, customer_id),
    CONSTRAINT FK_AccountHolder_Account FOREIGN KEY (account_id) REFERENCES Account(account_id),
    CONSTRAINT FK_AccountHolder_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
GO

-- Create Loan table
CREATE TABLE Loan (
    loan_id INT PRIMARY KEY IDENTITY(1,1),
    branch_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    start_date DATE NOT NULL,
    loan_officer_id INT NULL,
    CONSTRAINT FK_Loan_Branch FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    CONSTRAINT FK_Loan_Officer FOREIGN KEY (loan_officer_id) REFERENCES Employee(employee_id),
    CONSTRAINT CHK_Loan_Amount CHECK (amount > 0)
);
GO

-- Create LoanCustomer junction table
CREATE TABLE LoanCustomer (
    loan_id INT NOT NULL,
    customer_id INT NOT NULL,
    CONSTRAINT PK_LoanCustomer PRIMARY KEY (loan_id, customer_id),
    CONSTRAINT FK_LoanCustomer_Loan FOREIGN KEY (loan_id) REFERENCES Loan(loan_id),
    CONSTRAINT FK_LoanCustomer_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
GO

-- Create Payment table
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    loan_id INT NOT NULL,
    payment_number INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(15,2) NOT NULL,
    CONSTRAINT FK_Payment_Loan FOREIGN KEY (loan_id) REFERENCES Loan(loan_id),
    CONSTRAINT CHK_Payment_Amount CHECK (payment_amount > 0),
    CONSTRAINT UQ_Loan_Payment UNIQUE (loan_id, payment_number)
);
GO

-- Create Audit table (for Phase 2 triggers)
CREATE TABLE Audit (
    audit_id INT PRIMARY KEY IDENTITY(1,1),
    description TEXT NOT NULL,
    timestamp DATETIME DEFAULT GETDATE()
);
GO

-- Add JSON column to Customer table (Phase 2 requirement)
ALTER TABLE Customer 
ADD profile_metadata NVARCHAR(MAX); -- Using NVARCHAR(MAX) for JSON in SQL Server
GO

-- Add spatial data column to Branch table (Phase 2 requirement)
ALTER TABLE Branch 
ADD location GEOGRAPHY; -- Using GEOGRAPHY for spatial data in SQL Server
GO

-- Create indexes for better performance
CREATE INDEX IX_Account_Branch ON Account(branch_id);
CREATE INDEX IX_Account_Type ON Account(account_type);
CREATE INDEX IX_Loan_Branch ON Loan(branch_id);
CREATE INDEX IX_Payment_Loan ON Payment(loan_id);
CREATE INDEX IX_Customer_PersonalBanker ON Customer(personal_banker_id);
CREATE INDEX IX_Employee_Manager ON Employee(manager_id);
CREATE INDEX IX_ChequingOverdraft_Account ON ChequingOverdraft(account_id);
GO

-- Display confirmation message
PRINT 'SKS National Bank database created successfully! All tables, constraints, and indexes have been created :D :D :D';
GO