-- ============================================
-- File: 04_stored_procedures.sql
-- Purpose:
--   Creates stored procedures used by the system.
--
-- Procedures:
--   1. sp_AddEmployee
--   2. sp_SetPayRate
--   3. sp_GenerateWeeklyPayroll
-- ============================================

USE PayrollDB;
GO

-- ============================================
-- Procedure: sp_AddEmployee
-- Purpose:
--   Adds a new employee to the Employees table.
-- ============================================
CREATE PROCEDURE sp_AddEmployee
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @AddressLine VARCHAR(100),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @ZipCode VARCHAR(10),
    @Phone VARCHAR(20),
    @Email VARCHAR(100)
AS
BEGIN
    INSERT INTO Employees (
        FirstName,
        LastName,
        AddressLine,
        City,
        State,
        ZipCode,
        Phone,
        Email,
        IsActive
    )
    VALUES (
        @FirstName,
        @LastName,
        @AddressLine,
        @City,
        @State,
        @ZipCode,
        @Phone,
        @Email,
        1
    );
END;
GO

-- ============================================
-- Procedure: sp_SetPayRate
-- Purpose:
--   Inserts a new pay rate record for an employee.
--   Historical rates are preserved because each
--   change creates a new row with an effective date.
-- ============================================
CREATE PROCEDURE sp_SetPayRate
    @EmployeeID INT,
    @HourlyRate DECIMAL(10,2),
    @EffectiveDate DATE
AS
BEGIN
    INSERT INTO PayRates (
        EmployeeID,
        HourlyRate,
        EffectiveDate
    )
    VALUES (
        @EmployeeID,
        @HourlyRate,
        @EffectiveDate
    );
END;
GO

-- ============================================
-- Procedure: sp_GenerateWeeklyPayroll
-- Purpose:
--   Calculates weekly payroll for a given employee
--   and week.
--
-- Logic:
--   - Retrieves the employee's worked hours
--   - Finds the latest pay rate effective on or
--     before the payroll week
--   - Splits hours into regular and overtime
--   - Calculates gross pay
--   - Inserts the final result into Payroll
-- ============================================
CREATE PROCEDURE sp_GenerateWeeklyPayroll
    @EmployeeID INT,
    @WeekStartDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HoursWorked DECIMAL(5,2);
    DECLARE @HourlyRate DECIMAL(10,2);
    DECLARE @RegularHours DECIMAL(5,2);
    DECLARE @OvertimeHours DECIMAL(5,2);
    DECLARE @GrossPay DECIMAL(10,2);

    -- Get the hours worked for the employee during the specified week
    SELECT @HoursWorked = HoursWorked
    FROM HoursWorked
    WHERE EmployeeID = @EmployeeID
      AND WeekStartDate = @WeekStartDate;

    -- Get the most recent applicable pay rate
    SELECT TOP 1 @HourlyRate = HourlyRate
    FROM PayRates
    WHERE EmployeeID = @EmployeeID
      AND EffectiveDate <= @WeekStartDate
    ORDER BY EffectiveDate DESC, PayRateID DESC;

    -- Calculate regular hours (maximum 40)
    SET @RegularHours =
        CASE
            WHEN @HoursWorked > 40 THEN 40
            ELSE @HoursWorked
        END;

    -- Calculate overtime hours
    SET @OvertimeHours =
        CASE
            WHEN @HoursWorked > 40 THEN @HoursWorked - 40
            ELSE 0
        END;

    -- Calculate gross pay
    -- Regular pay = RegularHours * HourlyRate
    -- Overtime pay = OvertimeHours * HourlyRate * 1.5
    SET @GrossPay =
        (@RegularHours * @HourlyRate) +
        (@OvertimeHours * @HourlyRate * 1.5);

    -- Store payroll result
    INSERT INTO Payroll (
        EmployeeID,
        WeekStartDate,
        RegularHours,
        OvertimeHours,
        HourlyRate,
        GrossPay
    )
    VALUES (
        @EmployeeID,
        @WeekStartDate,
        @RegularHours,
        @OvertimeHours,
        @HourlyRate,
        @GrossPay
    );
END;
GO