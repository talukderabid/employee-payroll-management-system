-- ============================================
-- File: 05_triggers.sql
-- Purpose:
--   Creates database triggers for automatic actions.
--
-- Trigger:
--   1. trg_AuditPayRateChange
-- ============================================

USE PayrollDB;
GO

-- ============================================
-- Trigger: trg_AuditPayRateChange
-- Purpose:
--   Automatically logs pay rate changes whenever
--   a new row is inserted into PayRates.
--
-- Notes:
--   - OldRate is pulled from the previous pay rate
--     for the same employee
--   - NewRate is the newly inserted pay rate
--   - ChangeDate records when the change happened
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