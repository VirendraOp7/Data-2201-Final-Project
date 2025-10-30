USE SKS_National_Bank;
GO

-- ==============================
-- 1. Branch
-- ==============================
INSERT INTO Branch (branch_name, city, branch_address, total_deposits, total_loans)
VALUES
('Downtown Branch', 'Toronto', '123 King St W', 1200000.00, 450000.00),
('North York Branch', 'Toronto', '45 Finch Ave W', 800000.00, 300000.00),
('Scarborough Branch', 'Toronto', '5000 Markham Rd', 650000.00, 220000.00),
('Mississauga Branch', 'Mississauga', '90 Dundas St E', 900000.00, 350000.00),
('Brampton Branch', 'Brampton', '77 Queen St E', 700000.00, 280000.00),
('Hamilton Branch', 'Hamilton', '12 Main St W', 550000.00, 190000.00),
('Ottawa Branch', 'Ottawa', '100 Rideau St', 950000.00, 400000.00),
('London Branch', 'London', '200 Richmond St', 600000.00, 210000.00),
('Kitchener Branch', 'Kitchener', '300 King St E', 720000.00, 270000.00),
('Windsor Branch', 'Windsor', '400 Ouellette Ave', 500000.00, 180000.00);
GO

-- ==============================
-- 2. Customer
-- ==============================
INSERT INTO Customer (name, customer_home_address, city, country, postal_code)
VALUES
('John Smith', '101 Front St', 'Toronto', 'Canada', 'M5J1E3'),
('Jane Doe', '88 Elm St', 'Toronto', 'Canada', 'M5G1H6'),
('Michael Brown', '45 Queen St', 'Hamilton', 'Canada', 'L8P4X9'),
('Sarah Johnson', '10 Dundas St', 'Mississauga', 'Canada', 'L5B1M7'),
('David Lee', '55 Main St', 'Brampton', 'Canada', 'L6W2C7'),
('Emily Davis', '200 King St', 'Ottawa', 'Canada', 'K1P1A5'),
('Robert Wilson', '900 Richmond St', 'London', 'Canada', 'N6A3H1'),
('Jessica Taylor', '450 King St', 'Kitchener', 'Canada', 'N2G3W6'),
('Daniel Anderson', '77 Walker Rd', 'Windsor', 'Canada', 'N9A1E1'),
('Laura White', '300 Bloor St', 'Toronto', 'Canada', 'M4W1C8');
GO

-- ==============================
-- 3. Employee
-- ==============================
INSERT INTO Employee (name, employee_home_address, city, country, start_date, manager_id)
VALUES
('Alice Johnson', '12 Bay St', 'Toronto', 'Canada', '2020-01-10', NULL),
('Bob Martin', '34 Queen St', 'Toronto', 'Canada', '2021-02-15', 1),
('Carol Lee', '56 Yonge St', 'Toronto', 'Canada', '2019-03-20', 1),
('David Kim', '78 King St', 'Mississauga', 'Canada', '2022-04-01', 2),
('Emma Chen', '90 Lakeshore Rd', 'Brampton', 'Canada', '2023-05-01', 3),
('Frank Hall', '22 Main St', 'Hamilton', 'Canada', '2018-06-12', 1),
('Grace Park', '33 Wellington St', 'Ottawa', 'Canada', '2020-07-23', 6),
('Henry Adams', '44 Richmond St', 'London', 'Canada', '2019-08-15', 6),
('Ivy Nguyen', '55 King St', 'Kitchener', 'Canada', '2021-09-20', 7),
('Jack Thompson', '66 Ouellette Ave', 'Windsor', 'Canada', '2022-10-25', 8);
GO

-- ==============================
-- 4. Location
-- ==============================
INSERT INTO Location (location_name, location_type, branch_id)
VALUES
('Toronto HQ', 'Head Office', 1),
('North York Service Center', 'Service', 2),
('Scarborough Office', 'Service', 3),
('Mississauga Office', 'Service', 4),
('Brampton Center', 'Service', 5),
('Hamilton Branch Office', 'Service', 6),
('Ottawa Center', 'Service', 7),
('London Office', 'Service', 8),
('Kitchener Center', 'Service', 9),
('Windsor Center', 'Service', 10);
GO

-- ==============================
-- 5. EmployeeLocation
-- ==============================
INSERT INTO EmployeeLocation (employee_id, location_id)
VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);
GO

-- ==============================
-- 6. Account
-- ==============================
INSERT INTO Account (branch_id, account_type, balance, last_signin, interest_rate)
VALUES
(1, 'Savings', 5000.00, '2025-10-01', 1.25),
(2, 'Chequing', 2500.00, '2025-09-25', 0.50),
(3, 'Savings', 10000.00, '2025-09-30', 1.50),
(4, 'Chequing', 750.00, '2025-09-10', 0.25),
(5, 'Savings', 25000.00, '2025-10-05', 1.75),
(6, 'Chequing', 1800.00, '2025-10-10', 0.50),
(7, 'Savings', 4000.00, '2025-09-28', 1.25),
(8, 'Chequing', 600.00, '2025-09-20', 0.25),
(9, 'Savings', 8200.00, '2025-10-12', 1.50),
(10, 'Chequing', 1500.00, '2025-09-30', 0.50);
GO

-- ==============================
-- 7. ChequingOverdraft
-- ==============================
INSERT INTO ChequingOverdraft (account_id, check_number, overdraft_date, amount)
VALUES
(2, 'CHK1001', '2025-10-05', 200.00),
(4, 'CHK1002', '2025-10-07', 150.00),
(6, 'CHK1003', '2025-09-29', 300.00),
(8, 'CHK1004', '2025-09-30', 100.00),
(10, 'CHK1005', '2025-10-02', 250.00);
GO

-- ==============================
-- 8. AccountHolder
-- ==============================
INSERT INTO AccountHolder (account_id, customer_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);
GO

-- ==============================
-- 9. Loan
-- ==============================
INSERT INTO Loan (branch_id, amount, start_date, term_months, interest_rate, status)
VALUES
(1, 15000.00, '2025-01-01', 24, 5.00, 'active'),
(2, 25000.00, '2024-05-10', 36, 4.75, 'active'),
(3, 10000.00, '2023-03-15', 12, 6.00, 'closed'),
(4, 30000.00, '2024-07-20', 48, 4.50, 'active'),
(5, 5000.00, '2025-02-28', 6, 6.25, 'active'),
(6, 18000.00, '2023-09-01', 18, 5.75, 'closed'),
(7, 22000.00, '2025-04-01', 24, 5.00, 'active'),
(8, 9000.00, '2024-09-09', 12, 6.00, 'active'),
(9, 27000.00, '2025-03-15', 36, 4.25, 'active'),
(10, 12000.00, '2024-11-01', 24, 5.50, 'active');
GO

-- ==============================
-- 10. LoanCustomer
-- ==============================
INSERT INTO LoanCustomer (loan_id, customer_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);
GO

-- ==============================
-- 11. Payment
-- ==============================
INSERT INTO Payment (loan_id, payment_number, payment_date, payment_amount)
VALUES
(1, 1, '2025-02-01', 625.00),
(1, 2, '2025-03-01', 625.00),
(2, 1, '2025-01-15', 750.00),
(3, 1, '2024-04-15', 900.00),
(4, 1, '2025-06-01', 850.00),
(5, 1, '2025-04-01', 830.00),
(6, 1, '2024-01-15', 950.00),
(7, 1, '2025-05-01', 700.00),
(8, 1, '2025-10-01', 675.00),
(9, 1, '2025-05-15', 720.00);
GO
