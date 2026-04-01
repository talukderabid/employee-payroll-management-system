-- ============================================
-- File: 02_create_tables.sql
-- Purpose:
--   Creates all core tables for the Employee
--   Payroll Management System.
--
-- Tables created:
--   1. Employees
--   2. PayRates
--   3. HoursWorked
--   4. Payroll
--   5. PayRateAudit
-- ============================================

USE PayrollDB;
GO

-- ============================================
-- Table: Employees
-- Purpose:
--   Stores employee personal and contact details.
-- ============================================
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1), -- Unique employee identifier
    FirstName VARCHAR(50) NOT NULL,           -- Employee first name
    LastName VARCHAR(50) NOT NULL,            -- Employee last name
    AddressLine VARCHAR(100),                 -- Street address
    City VARCHAR(50),                         -- City
    State VARCHAR(50),                        -- State
    ZipCode VARCHAR(10),                      -- ZIP / postal code
    Phone VARCHAR(20),                        -- Contact number
    Email VARCHAR(100),                       -- Email address
    IsActive BIT DEFAULT 1                    -- 1 = active employee, 0 = inactive
);
GO

-- ============================================
-- Table: PayRates
-- Purpose:
--   Stores hourly pay rates for employees.
--   EffectiveDate allows future or historical
--   pay rate tracking.
-- ============================================
CREATE TABLE PayRates (
    PayRateID INT PRIMARY KEY IDENTITY(1,1),  -- Unique pay rate record ID
    EmployeeID INT NOT NULL,                  -- Links pay rate to employee
    HourlyRate DECIMAL(10,2) NOT NULL,        -- Hourly pay amount
    EffectiveDate DATE NOT NULL,              -- Date this pay rate becomes effective

    CONSTRAINT FK_PayRates_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- ============================================
-- Table: HoursWorked
-- Purpose:
--   Stores weekly hours entered for employees.
-- ============================================
CREATE TABLE HoursWorked (
    HoursWorkedID INT PRIMARY KEY IDENTITY(1,1), -- Unique hours record ID
    EmployeeID INT NOT NULL,                     -- Links hours to employee
    WeekStartDate DATE NOT NULL,                 -- Start date of work week
    HoursWorked DECIMAL(5,2) NOT NULL,           -- Total hours worked that week

    CONSTRAINT FK_HoursWorked_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- ============================================
-- Table: Payroll
-- Purpose:
--   Stores generated payroll results for a week.
-- ============================================
CREATE TABLE Payroll (
    PayrollID INT PRIMARY KEY IDENTITY(1,1), -- Unique payroll record ID
    EmployeeID INT NOT NULL,                 -- Links payroll record to employee
    WeekStartDate DATE NOT NULL,             -- Payroll week start date
    RegularHours DECIMAL(5,2) NOT NULL,      -- Hours up to 40
    OvertimeHours DECIMAL(5,2) NOT NULL,     -- Hours above 40
    HourlyRate DECIMAL(10,2) NOT NULL,       -- Hourly rate used for payroll calculation
    GrossPay DECIMAL(10,2) NOT NULL,         -- Total gross pay for the week

    CONSTRAINT FK_Payroll_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- ============================================
-- Table: PayRateAudit
-- Purpose:
--   Stores a history of pay rate changes.
--   This table is populated by a trigger.
-- ============================================
CREATE TABLE PayRateAudit (
    AuditID INT PRIMARY KEY IDENTITY(1,1), -- Unique audit record ID
    EmployeeID INT NOT NULL,               -- Employee whose rate changed
    OldRate DECIMAL(10,2),                 -- Previous hourly rate
    NewRate DECIMAL(10,2),                 -- New hourly rate
    ChangeDate DATETIME DEFAULT GETDATE(), -- Timestamp of change

    CONSTRAINT FK_PayRateAudit_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO