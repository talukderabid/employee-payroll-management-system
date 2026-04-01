-- ============================================
-- File: 07_roles_and_permissions.sql
-- Purpose:
--   Creates SQL Server logins, database users,
--   roles, and permissions for access control.
--
-- Roles created:
--   1. PayrollAdminRole
--   2. PayrollClerkRole
--   3. PayrollViewerRole
--
-- Security model:
--   - Admin: full data access and procedure access
--   - Clerk: can view data, insert hours, run some
--     payroll procedures
--   - Viewer: read-only access
-- ============================================

-- ============================================
-- Step 1: Create SQL Server logins
-- These are server-level logins used to connect.
-- ============================================
USE master;
GO

CREATE LOGIN PayrollAdminLogin WITH PASSWORD = 'Admin@12345';
CREATE LOGIN PayrollClerkLogin WITH PASSWORD = 'Clerk@12345';
CREATE LOGIN PayrollViewerLogin WITH PASSWORD = 'Viewer@12345';
GO

-- ============================================
-- Step 2: Set default database for each login
-- This helps users land directly in PayrollDB.
-- ============================================
ALTER LOGIN PayrollAdminLogin WITH DEFAULT_DATABASE = PayrollDB;
ALTER LOGIN PayrollClerkLogin WITH DEFAULT_DATABASE = PayrollDB;
ALTER LOGIN PayrollViewerLogin WITH DEFAULT_DATABASE = PayrollDB;
GO

-- ============================================
-- Step 3: Create database users mapped to logins
-- These are database-level identities inside PayrollDB.
-- ============================================
USE PayrollDB;
GO

CREATE USER PayrollAdminUser FOR LOGIN PayrollAdminLogin;
CREATE USER PayrollClerkUser FOR LOGIN PayrollClerkLogin;
CREATE USER PayrollViewerUser FOR LOGIN PayrollViewerLogin;
GO

-- ============================================
-- Step 4: Create database roles
-- Roles are used to group permissions.
-- ============================================
CREATE ROLE PayrollAdminRole;
CREATE ROLE PayrollClerkRole;
CREATE ROLE PayrollViewerRole;
GO

-- ============================================
-- Step 5: Add users to roles
-- ============================================
ALTER ROLE PayrollAdminRole ADD MEMBER PayrollAdminUser;
ALTER ROLE PayrollClerkRole ADD MEMBER PayrollClerkUser;
ALTER ROLE PayrollViewerRole ADD MEMBER PayrollViewerUser;
GO

-- ============================================
-- Step 6: Grant Admin permissions
-- Admin can fully manage all tables and execute
-- all major stored procedures.
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON Employees TO PayrollAdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON PayRates TO PayrollAdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON HoursWorked TO PayrollAdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Payroll TO PayrollAdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON PayRateAudit TO PayrollAdminRole;

GRANT EXECUTE ON OBJECT::dbo.sp_AddEmployee TO PayrollAdminRole;
GRANT EXECUTE ON OBJECT::dbo.sp_SetPayRate TO PayrollAdminRole;
GRANT EXECUTE ON OBJECT::dbo.sp_GenerateWeeklyPayroll TO PayrollAdminRole;
GO

-- ============================================
-- Step 7: Grant Payroll Clerk permissions
-- Clerk can:
--   - view employee/payroll data
--   - insert hours worked
--   - execute selected payroll procedures
-- Clerk cannot delete employees.
-- ============================================
GRANT SELECT ON Employees TO PayrollClerkRole;
GRANT SELECT ON PayRates TO PayrollClerkRole;
GRANT SELECT, INSERT ON HoursWorked TO PayrollClerkRole;
GRANT SELECT ON Payroll TO PayrollClerkRole;
GRANT SELECT ON PayRateAudit TO PayrollClerkRole;

GRANT EXECUTE ON OBJECT::dbo.sp_SetPayRate TO PayrollClerkRole;
GRANT EXECUTE ON OBJECT::dbo.sp_GenerateWeeklyPayroll TO PayrollClerkRole;
GO

-- ============================================
-- Step 8: Grant Viewer permissions
-- Viewer is read-only across the system.
-- ============================================
GRANT SELECT ON Employees TO PayrollViewerRole;
GRANT SELECT ON PayRates TO PayrollViewerRole;
GRANT SELECT ON HoursWorked TO PayrollViewerRole;
GRANT SELECT ON Payroll TO PayrollViewerRole;
GRANT SELECT ON PayRateAudit TO PayrollViewerRole;
GO