# Employee Payroll Management System (SQL Server)

## Overview
This project is a backend-focused Employee Payroll Management System built using SQL Server. It manages employee records, pay rates, work hours, payroll generation, and role-based access control.

## Current Main Features
- Add and manage employees
- Assign and track pay rates
- Record weekly hours worked
- Generate weekly payroll
- Audit pay rate changes using a trigger
- Control access using logins, users, and roles

## SQL Server Concepts Used
- Tables with primary keys and foreign keys
- Stored procedures
- Triggers
- Reporting queries
- Logins, users, roles, and permissions

## Files
- 01_create_database.sql
  → creates the database
  
- 02_create_tables.sql
  → creates all project tables
  
- 03_insert_sample_data.sql
  → inserts sample records
  
- 04_stored_procedures.sql
  → creates procedures
  
- 05_triggers.sql
  → creates triggers
  
- 06_demo_queries.sql
  → contains presentation queries
  
- 07_roles_and_permissions.sql
  → sets up security

## Frontend Implementation

The frontend of the application was developed using Flask templates (Jinja2) along with custom CSS for styling.
The goal was to create a simple, user-friendly interface that connects directly to backend functionality.

Key Features
Multi-page navigation
Home dashboard
Active employees
Inactive employees
Add employee
Set pay rate
Enter hours
Generate payroll
Dynamic templates

Data is rendered using Jinja loops ({% for %})

Forms send data to backend using POST requests
Reusable layout using base.html
Employee management UI
Active employees displayed in a table
Deactivate button for each employee
Separate page for inactive employees
Reactivate option available for inactive employees
Form-based workflows
Add employee form
Set pay rate form
Enter hours form
Generate payroll form
Payroll display and PDF download
Payroll results displayed in a structured table
Option to download payslip as a PDF

Styling (CSS)
Custom CSS implemented in static/style.css
Features include:
Navigation bar
Styled tables
Form layouts
Button styles (primary, success, danger)
Dashboard-style home page
Home Dashboard
Converted home route to a template (home.html)
Added:
Intro section (system description)
Quick action buttons
Dashboard cards for each feature
Error Handling (UI Level)
Deactivation errors handled gracefully
Popup alert shown if employee cannot be deactivated due to payroll records
Prevents raw database errors from reaching the user

##Future Plans
mail notifications
sleek(er) UI/UX
local application for offline usage.

