-- ============================================
-- File: 08_demo_test_flow.sql
-- Purpose:
--   Demonstrates the system from employee creation
--   to payroll generation.
-- ============================================

USE PayrollDB;
GO

-- Add a new employee
EXEC sp_AddEmployee
    @FirstName = 'Chris',
    @LastName = 'Taylor',
    @AddressLine = '999 Test St',
    @City = 'Shreveport',
    @State = 'LA',
    @ZipCode = '71101',
    @Phone = '3185559999',
    @Email = 'chris.taylor@email.com';
GO

-- View employees to confirm insert
SELECT * FROM Employees;
GO

-- Set pay rate for the new employee
EXEC sp_SetPayRate
    @EmployeeID = 6,
    @HourlyRate = 21.75,
    @EffectiveDate = '2026-04-01';
GO

-- Add another pay rate to test audit trigger
EXEC sp_SetPayRate
    @EmployeeID = 6,
    @HourlyRate = 23.00,
    @EffectiveDate = '2026-04-15';
GO

-- Insert weekly hours worked
INSERT INTO HoursWorked (EmployeeID, WeekStartDate, HoursWorked)
VALUES (6, '2026-04-06', 42.00);
GO

-- Generate payroll
EXEC sp_GenerateWeeklyPayroll
    @EmployeeID = 6,
    @WeekStartDate = '2026-04-06';
GO

-- Show payroll result
SELECT * FROM Payroll WHERE EmployeeID = 6;
GO

-- Show pay rate audit trail
SELECT * FROM PayRateAudit WHERE EmployeeID = 6;
GO