-- ============================================
-- File: 05_triggers.sql
-- Purpose:
--   Creates triggers used for validation,
--   data integrity, and auditing in the
--   Employee Payroll Management System.
--
-- Triggers included:
--   1. trg_AuditPayRateChange
--   2. trg_PreventNegativeHours
--   3. trg_ValidatePayRate
--   4. trg_ValidateHoursDate
--   5. trg_PreventDeactivateWithPayroll
-- ============================================

USE PayrollDB;
GO

-- ============================================
-- Trigger 1: trg_AuditPayRateChange
-- Purpose:
--   Automatically logs pay rate changes whenever
--   a new pay rate is inserted into the PayRates table.
--
-- Logic:
--   - Finds the previous pay rate for the employee
--   - Stores the old rate and new rate in PayRateAudit
--   - Records the time of the change
-- ============================================
CREATE TRIGGER trg_AuditPayRateChange
ON PayRates
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PayRateAudit (
        EmployeeID,
        OldRate,
        NewRate,
        ChangeDate
    )
    SELECT
        i.EmployeeID,
        (
            SELECT TOP 1 pr.HourlyRate
            FROM PayRates pr
            WHERE pr.EmployeeID = i.EmployeeID
              AND pr.PayRateID < i.PayRateID
            ORDER BY pr.EffectiveDate DESC, pr.PayRateID DESC
        ) AS OldRate,
        i.HourlyRate AS NewRate,
        GETDATE()
    FROM inserted i;
END;
GO

-- ============================================
-- Trigger 2: trg_PreventNegativeHours
-- Purpose:
--   Prevents insertion or update of negative
--   hours worked in the HoursWorked table.
--
-- Why:
--   Negative working hours are invalid and would
--   corrupt payroll calculations.
-- ============================================
CREATE TRIGGER trg_PreventNegativeHours
ON HoursWorked
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE HoursWorked < 0
    )
    BEGIN
        RAISERROR ('Hours worked cannot be negative.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ============================================
-- Trigger 3: trg_ValidatePayRate
-- Purpose:
--   Prevents insertion or update of an invalid
--   hourly pay rate in the PayRates table.
--
-- Rule:
--   HourlyRate must be greater than zero.
--
-- Why:
--   A zero or negative pay rate is not valid
--   for payroll processing.
-- ============================================
CREATE TRIGGER trg_ValidatePayRate
ON PayRates
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE HourlyRate <= 0
    )
    BEGIN
        RAISERROR ('Hourly rate must be greater than zero.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ============================================
-- Trigger 4: trg_ValidateHoursDate
-- Purpose:
--   Prevents entering work hours for a future week.
--
-- Rule:
--   WeekStartDate cannot be greater than the
--   current date.
--
-- Why:
--   Hours should only be recorded for work that
--   has already occurred.
-- ============================================
CREATE TRIGGER trg_ValidateHoursDate
ON HoursWorked
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE WeekStartDate > CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR ('Cannot enter hours for a future date.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ============================================
-- Trigger 5: trg_PreventDeactivateWithPayroll
-- Purpose:
--   Prevents an employee from being marked inactive
--   if payroll records already exist for that employee.
--
-- Rule:
--   If IsActive is being changed to 0, and the employee
--   already has payroll records, the update is blocked.
--
-- Why:
--   This protects payroll history and prevents
--   improper deactivation of employees with
--   existing payroll transactions.
-- ============================================
CREATE TRIGGER trg_PreventDeactivateWithPayroll
ON Employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d
            ON i.EmployeeID = d.EmployeeID
        JOIN Payroll p
            ON i.EmployeeID = p.EmployeeID
        WHERE d.IsActive = 1
          AND i.IsActive = 0
    )
    BEGIN
        RAISERROR ('Cannot deactivate employee with existing payroll records.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
