-- Test usp_BeginStateEvent
/*DECLARE @beginTime datetime = SYSUTCDATETIME()
DECLARE @equipmentId int = oee.fn_FindEquipmentByPath ('Site/Area/Line 1')
DECLARE @stateId int = oee.fn_FindEquipmentStateByValue (@equipmentId, 0)
EXECUTE oee.usp_BeginStateEvent @equipmentId, @stateId, @beginTime*/

-- Test usp_BeginJobEvent
/*DECLARE @beginTime datetime = SYSUTCDATETIME()
DECLARE @equipmentId int = oee.fn_FindEquipmentByPath ('Site/Area/Line 2')
DECLARE @jobId int, @jobEventId int
EXECUTE oee.usp_FindOrCreateJobByReference '1000002', @jobId OUTPUT
EXECUTE oee.usp_BeginJobEvent @equipmentId, @jobId, @beginTime
SELECT * FROM oee.Jobs
SELECT * FROM oee.JobEvents*/

-- Test usp_BeginShiftEvent
DECLARE @beginTime datetime = SYSUTCDATETIME()
DECLARE @shiftScheduleId int = oee.fn_FindShiftScheduleByName ('Operations')
DECLARE @shiftId int = oee.fn_FindShiftByName (@shiftScheduleId, 'A')
EXECUTE oee.usp_BeginShiftEvent @shiftScheduleId, @shiftId, @beginTime
SELECT * FROM oee.ShiftEvents

-- Select all from EquipmentEvents, calculate Minutes
SELECT *, CONVERT(float, DATEDIFF(ms, BeginTime, ISNULL(EndTime, SYSUTCDATETIME()))) / 60000 Minutes
FROM oee.EquipmentEvents
