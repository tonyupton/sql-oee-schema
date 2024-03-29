DROP TABLE IF EXISTS OEE.CounterEvents
go

DROP TABLE IF EXISTS OEE.Counters
go

DROP TABLE IF EXISTS OEE.EquipmentEvents
go

DROP TABLE IF EXISTS OEE.JobEvents
go

DROP TABLE IF EXISTS OEE.Jobs
go

DROP TABLE IF EXISTS OEE.PerformanceEvents
go

DROP TABLE IF EXISTS OEE.ShiftEvents
go

DROP TABLE IF EXISTS OEE.Shifts
go

DROP TABLE IF EXISTS OEE.ShiftSchedules
go

DROP TABLE IF EXISTS OEE.StateEvents
go

DROP TABLE IF EXISTS OEE.Equipment
go

DROP TABLE IF EXISTS OEE.StateReasons
go

DROP TABLE IF EXISTS OEE.States
go

DROP TABLE IF EXISTS OEE.StateClasses
go

DROP FUNCTION IF EXISTS OEE.fn_FindEquipmentByPath
go

DROP FUNCTION IF EXISTS OEE.fn_FindEquipmentStateByName
go

DROP FUNCTION IF EXISTS OEE.fn_FindEquipmentStateByValue
go

DROP FUNCTION IF EXISTS OEE.fn_FindJobByReference
go

DROP FUNCTION IF EXISTS OEE.fn_FindLastEquipmentEvent
go

DROP FUNCTION IF EXISTS OEE.fn_FindLastJobEvent
go

DROP FUNCTION IF EXISTS OEE.fn_FindLastShiftEvent
go

DROP FUNCTION IF EXISTS OEE.fn_FindLastStateEvent
go

DROP FUNCTION IF EXISTS OEE.fn_FindShiftByName
go

DROP FUNCTION IF EXISTS OEE.fn_FindShiftScheduleByName
go

DROP PROCEDURE IF EXISTS OEE.usp_BeginEquipmentEvent
go

DROP PROCEDURE IF EXISTS OEE.usp_BeginJobEvent
go

DROP PROCEDURE IF EXISTS OEE.usp_BeginShiftEvent
go

DROP PROCEDURE IF EXISTS OEE.usp_BeginStateEvent
go

DROP PROCEDURE IF EXISTS OEE.usp_FindOrCreateJobByReference
go