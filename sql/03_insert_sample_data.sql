-- ============================================
-- File: 03_insert_sample_data.sql
-- Purpose:
--   Inserts sample employees, pay rates, and
--   hours worked for testing and demonstration.
-- ============================================

USE PayrollDB;
GO

-- ============================================
-- Insert sample employees
-- ============================================
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
VALUES
('John',   'Smith',   '123 Oak St',   'Shreveport',  'LA', '71101', '3185551001', 'john.smith@email.com',   1),
('Emily',  'Johnson', '456 Pine Ave', 'Bossier City','LA', '71111', '3185551002', 'emily.johnson@email.com',1),
('Michael','Brown',   '789 Cedar Rd', 'Shreveport',  'LA', '71105', '3185551003', 'michael.brown@email.com',1),
('Sarah',  'Davis',   '321 Elm St',   'Minden',      'LA', '71055', '3185551004', 'sarah.davis@email.com',  1),
('David',  'Wilson',  '654 Maple Dr', 'Ruston',      'LA', '71270', '3185551005', 'david.wilson@email.com', 1);
GO

-- ============================================
-- Insert starting pay rates for employees
-- ============================================
INSERT INTO PayRates (
    EmployeeID,
    HourlyRate,
    EffectiveDate
)
VALUES
(1, 20.00, '2026-03-01'),
(2, 22.50, '2026-03-01'),
(3, 18.75, '2026-03-01'),
(4, 25.00, '2026-03-01'),
(5, 19.50, '2026-03-01');
GO

-- ============================================
-- Insert weekly hours worked
-- ============================================
INSERT INTO HoursWorked (
    EmployeeID,
    WeekStartDate,
    HoursWorked
)
VALUES
(1, '2026-03-30', 40.00),
(2, '2026-03-30', 42.50),
(3, '2026-03-30', 38.00),
(4, '2026-03-30', 45.00),
(5, '2026-03-30', 36.50);
GO