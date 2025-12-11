/*MADE BY MO*/

/* ================================
   CREATE USERS & ASSIGN PRIVILEGES
   SKS National Bank – Phase 2
   ================================= */

/*  
   CUSTOMER USER  
   - Login: customer_group_X  
   - Password: customer  
   - Can READ ONLY customer-related tables:
        Customer
        Account
        AccountHolder
        ChequingOverdraft
        Loan
        LoanCustomer
        Payment
        CustomerEmployee
*/

-- Create login
CREATE LOGIN customer_group_X WITH PASSWORD = 'customer';

-- Create user inside the database
CREATE USER customer_group_X FOR LOGIN customer_group_X;

-- Grant read-only access on customer-related tables
GRANT SELECT ON Customer            TO customer_group_X;
GRANT SELECT ON Account             TO customer_group_X;
GRANT SELECT ON AccountHolder       TO customer_group_X;
GRANT SELECT ON ChequingOverdraft   TO customer_group_X;
GRANT SELECT ON Loan                TO customer_group_X;
GRANT SELECT ON LoanCustomer        TO customer_group_X;
GRANT SELECT ON Payment             TO customer_group_X;
GRANT SELECT ON CustomerEmployee    TO customer_group_X;



/*
   ACCOUNTANT USER  
   - Login: accountant_group_X  
   - Password: accountant  
   - Can READ ALL TABLES  
   - CANNOT INSERT, UPDATE, DELETE in Account, Payment, Loan  
*/

-- Create login
CREATE LOGIN accountant_group_X WITH PASSWORD = 'accountant';

-- Create user inside the database
CREATE USER accountant_group_X FOR LOGIN accountant_group_X;

-- Grant read access on ALL tables
GRANT SELECT ON Branch              TO accountant_group_X;
GRANT SELECT ON Customer            TO accountant_group_X;
GRANT SELECT ON Employee            TO accountant_group_X;
GRANT SELECT ON Location            TO accountant_group_X;
GRANT SELECT ON EmployeeLocation    TO accountant_group_X;
GRANT SELECT ON Account             TO accountant_group_X;
GRANT SELECT ON AccountHolder       TO accountant_group_X;
GRANT SELECT ON ChequingOverdraft   TO accountant_group_X;
GRANT SELECT ON Loan                TO accountant_group_X;
GRANT SELECT ON LoanCustomer        TO accountant_group_X;
GRANT SELECT ON Payment             TO accountant_group_X;
GRANT SELECT ON CustomerEmployee    TO accountant_group_X;

-- REVOKE write access on account-related tables
REVOKE INSERT, UPDATE, DELETE ON Account   FROM accountant_group_X;
REVOKE INSERT, UPDATE, DELETE ON Loan      FROM accountant_group_X;
REVOKE INSERT, UPDATE, DELETE ON Payment   FROM accountant_group_X;



/* ================================
   TESTING PRIVILEGES
   ================================ */

-- TEST 1: Customer should succeed (SELECT)
EXECUTE AS USER = 'customer_group_X';
SELECT TOP 5 * FROM Customer;
REVERT;

-- TEST 2: Customer should fail (INSERT attempt)
EXECUTE AS USER = 'customer_group_X';
INSERT INTO Customer(first_name) VALUES ('FAIL TEST');
REVERT;

-- TEST 3: Accountant should succeed (SELECT)
EXECUTE AS USER = 'accountant_group_X';
SELECT TOP 5 * FROM Account;
REVERT;

-- TEST 4: Accountant should fail (UPDATE on restricted table)
EXECUTE AS USER = 'accountant_group_X';
UPDATE Account SET balance = 0 WHERE account_id = 1;
REVERT;

