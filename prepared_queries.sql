USE SKS_National_Bank;
GO
/**********************************************************************
1) sp_create_account
Purpose: Create a new account for a branch with an initial deposit 
         and return the new account ID.
**********************************************************************/
DROP PROCEDURE IF EXISTS sp_create_account;
GO
CREATE PROCEDURE sp_create_account
  @branch_id INT,
  @account_type VARCHAR(20),
  @initial_deposit DECIMAL(15,2),
  @interest_rate DECIMAL(5,2)
AS
BEGIN
  INSERT INTO Account (branch_id, account_type, balance, last_signin, interest_rate)
  VALUES (@branch_id, @account_type, @initial_deposit, GETDATE(), @interest_rate);

  SELECT SCOPE_IDENTITY() AS new_account_id;
END;
GO

-- Test
EXEC sp_create_account @branch_id = 1, @account_type = 'Savings', @initial_deposit = 1500.00, @interest_rate = 1.25;
GO

/**********************************************************************
2) sp_record_payment
Purpose: Record a loan payment and update the loan status if fully paid.
**********************************************************************/
DROP PROCEDURE IF EXISTS sp_record_payment;
GO
CREATE PROCEDURE sp_record_payment
  @loan_id INT,
  @payment_amount DECIMAL(15,2)
AS
BEGIN
  DECLARE @next_payment_number INT = 
      ISNULL((SELECT MAX(payment_number) + 1 FROM Payment WHERE loan_id = @loan_id), 1);

  INSERT INTO Payment (loan_id, payment_number, payment_date, payment_amount)
  VALUES (@loan_id, @next_payment_number, GETDATE(), @payment_amount);

  -- Optional: Update loan status if total payments >= loan amount
  DECLARE @total_paid DECIMAL(15,2) = (SELECT SUM(payment_amount) FROM Payment WHERE loan_id = @loan_id);
  DECLARE @loan_total DECIMAL(15,2) = (SELECT amount FROM Loan WHERE loan_id = @loan_id);

  IF @total_paid >= @loan_total
    UPDATE Loan SET status = 'closed' WHERE loan_id = @loan_id;
END;
GO

-- Test
EXEC sp_record_payment @loan_id = 1, @payment_amount = 1000.00;
GO

/**********************************************************************
3) fn_get_customer_balance
Purpose: Return the total balance of all accounts held by a given customer.
**********************************************************************/
DROP FUNCTION IF EXISTS fn_get_customer_balance;
GO
CREATE FUNCTION fn_get_customer_balance(@customer_id INT)
RETURNS DECIMAL(15,2)
AS
BEGIN
  DECLARE @total_balance DECIMAL(15,2);

  SELECT @total_balance = SUM(a.balance)
  FROM Account a
  JOIN AccountHolder ah ON a.account_id = ah.account_id
  WHERE ah.customer_id = @customer_id;

  RETURN ISNULL(@total_balance, 0.00);
END;
GO

-- Test
SELECT dbo.fn_get_customer_balance(3) AS total_balance_for_customer;
GO

/**********************************************************************
4) sp_branch_summary
Purpose: Show total deposits, total loans, and number of accounts 
         for a specific branch.
**********************************************************************/
DROP PROCEDURE IF EXISTS sp_branch_summary;
GO
CREATE PROCEDURE sp_branch_summary @branch_id INT
AS
BEGIN
  SELECT 
    b.branch_name,
    b.city,
    COUNT(a.account_id) AS total_accounts,
    SUM(a.balance) AS total_account_balance,
    b.total_loans,
    b.total_deposits
  FROM Branch b
  LEFT JOIN Account a ON b.branch_id = a.branch_id
  WHERE b.branch_id = @branch_id
  GROUP BY b.branch_name, b.city, b.total_loans, b.total_deposits;
END;
GO

-- Test
EXEC sp_branch_summary @branch_id = 1;
GO

/**********************************************************************
5) fn_customer_loan_count
Purpose: Return the number of active loans a customer currently has.
**********************************************************************/
DROP FUNCTION IF EXISTS fn_customer_loan_count;
GO
CREATE FUNCTION fn_customer_loan_count(@customer_id INT)
RETURNS INT
AS
BEGIN
  DECLARE @loan_count INT;

  SELECT @loan_count = COUNT(*)
  FROM Loan l
  JOIN LoanCustomer lc ON l.loan_id = lc.loan_id
  WHERE lc.customer_id = @customer_id AND l.status = 'active';

  RETURN ISNULL(@loan_count, 0);
END;
GO

-- Test
SELECT dbo.fn_customer_loan_count(2) AS active_loans_for_customer;
GO

/**********************************************************************
6) sp_update_account_balance
Purpose: Update an account balance after a deposit or withdrawal.
**********************************************************************/
DROP PROCEDURE IF EXISTS sp_update_account_balance;
GO
CREATE PROCEDURE sp_update_account_balance
  @account_id INT,
  @amount DECIMAL(15,2),
  @transaction_type VARCHAR(10)
AS
BEGIN
  IF @transaction_type = 'deposit'
    UPDATE Account SET balance = balance + @amount WHERE account_id = @account_id;
  ELSE IF @transaction_type = 'withdraw'
    UPDATE Account SET balance = balance - @amount WHERE account_id = @account_id;

  SELECT account_id, balance FROM Account WHERE account_id = @account_id;
END;
GO

-- Test
EXEC sp_update_account_balance @account_id = 1, @amount = 500.00, @transaction_type = 'deposit';
GO

/**********************************************************************
7) sp_assign_employee_to_location
Purpose: Assign an employee to a specific location.
**********************************************************************/
DROP PROCEDURE IF EXISTS sp_assign_employee_to_location;
GO
CREATE PROCEDURE sp_assign_employee_to_location
  @employee_id INT,
  @location_id INT
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM EmployeeLocation WHERE employee_id = @employee_id AND location_id = @location_id)
  BEGIN
    INSERT INTO EmployeeLocation (employee_id, location_id)
    VALUES (@employee_id, @location_id);
  END

  SELECT * FROM EmployeeLocation WHERE employee_id = @employee_id;
END;
GO

-- Test
EXEC sp_assign_employee_to_location @employee_id = 1, @location_id = 2;
GO

/**********************************************************************
8) fn_branch_total_loans
Purpose: Return total loan amount issued by a specific branch.
**********************************************************************/
DROP FUNCTION IF EXISTS fn_branch_total_loans;
GO
CREATE FUNCTION fn_branch_total_loans(@branch_id INT)
RETURNS DECIMAL(15,2)
AS
BEGIN
  DECLARE @total DECIMAL(15,2);

  SELECT @total = SUM(amount)
  FROM Loan
  WHERE branch_id = @branch_id;

  RETURN ISNULL(@total, 0.00);
END;
GO

-- Test
SELECT dbo.fn_branch_total_loans(1) AS total_loans_for_branch1;
GO

/**********************************************************************
9) sp_generate_customer_report
Purpose: Generate a customer report including name, total balance,
         and number of active loans.
**********************************************************************/
DROP PROCEDURE IF EXISTS sp_generate_customer_report;
GO
CREATE PROCEDURE sp_generate_customer_report
AS
BEGIN
  SELECT 
    c.customer_id,
    c.name,
    dbo.fn_get_customer_balance(c.customer_id) AS total_balance,
    dbo.fn_customer_loan_count(c.customer_id) AS active_loans
  FROM Customer c;
END;
GO

-- Test
EXEC sp_generate_customer_report;
GO

/**********************************************************************
10) sp_get_overdrafts_above
Purpose: List all chequing overdrafts greater than a given amount.
**********************************************************************/
DROP PROCEDURE IF EXISTS sp_get_overdrafts_above;
GO
CREATE PROCEDURE sp_get_overdrafts_above
  @min_amount DECIMAL(15,2)
AS
BEGIN
  SELECT 
    co.overdraft_id,
    co.account_id,
    a.account_type,
    co.amount,
    co.overdraft_date
  FROM ChequingOverdraft co
  JOIN Account a ON co.account_id = a.account_id
  WHERE co.amount > @min_amount;
END;
GO

-- Test
EXEC sp_get_overdrafts_above @min_amount = 100.00;
GO
