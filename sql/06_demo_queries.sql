-- ============================================
-- File: 06_demo_queries.sql
-- Purpose:
--   Contains presentation-ready queries for demo.
--
-- Queries included:
--   1. View all employees
--   2. Weekly payroll report
--   3. Employees who worked overtime
--   4. Total payroll cost by week
--   5. Pay rate history for one employee
--   6. Audit trail of pay rate changes
-- ============================================

USE PayrollDB;
GO

-- ============================================
-- Query 1: View all employees
-- Purpose:
--   Displays basic employee information.
-- ============================================
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    City,
    State,
    Phone,
    Email,
    IsActive
FROM Employees;
GO

-- ============================================
-- Query 2: Weekly payroll report
-- Purpose:
--   Shows payroll results joined with employee names.
-- ============================================
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    p.WeekStartDate,
    p.RegularHours,
    p.OvertimeHours,
    p.HourlyRate,
    p.GrossPay
FROM Payroll p
JOIN Employees e
    ON p.EmployeeID = e.EmployeeID
ORDER BY p.WeekStartDate, e.EmployeeID;
GO

-- ============================================
-- Query 3: Employees who worked overtime
-- Purpose:
--   Lists employees whose hours exceeded 40.
-- ============================================
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    h.WeekStartDate,
    h.HoursWorked
FROM HoursWorked h
JOIN Employees e
    ON h.EmployeeID = e.EmployeeID
WHERE h.HoursWorked > 40
ORDER BY h.HoursWorked DESC;
GO

-- ============================================
-- Query 4: Total payroll cost for each week
-- Purpose:
--   Summarizes the company's total weekly payroll.
-- ============================================
SELECT 
    WeekStartDate,
    SUM(GrossPay) AS TotalWeeklyPayroll
FROM Payroll
GROUP BY WeekStartDate;
GO

-- ============================================
-- Query 5: Pay rate history for a specific employee
-- Purpose:
--   Displays pay rate changes over time.
-- Note:
--   EmployeeID = 6 was used for Chris in testing.
-- ============================================
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    pr.HourlyRate,
    pr.EffectiveDate
FROM PayRates pr
JOIN Employees e
    ON pr.EmployeeID = e.EmployeeID
WHERE e.EmployeeID = 6
ORDER BY pr.EffectiveDate DESC;
GO

-- ============================================
-- Query 6: Audit trail of pay rate changes
-- Purpose:
--   Displays records inserted by the audit trigger.
-- ============================================
SELECT 
    a.AuditID,
    a.EmployeeID,
    e.FirstName,
    e.LastName,
    a.OldRate,
    a.NewRate,
    a.ChangeDate
FROM PayRateAudit a
JOIN Employees e
    ON a.EmployeeID = e.EmployeeID
ORDER BY a.ChangeDate DESC;
GO