-- Test usp_BeginStateEvent
DECLARE @beginTime datetime = SYSUTCDATETIME()
DECLARE @equipmentId int = OEE.fn_FindEquipmentByPath ('Enterprise/Site/Area/Line 1')
DECLARE @stateId int = OEE.fn_FindEquipmentStateByValue (@equipmentId, 0)
EXECUTE OEE.usp_BeginStateEvent @equipmentId, @stateId, @beginTime

-- Test usp_BeginJobEvent
--DECLARE @beginTime datetime = SYSUTCDATETIME()
--DECLARE @equipmentId int = OEE.fn_FindEquipmentByPath ('Enterprise/Site/Area/Line 2')
DECLARE @jobId int, @jobEventId int
EXECUTE OEE.usp_FindOrCreateJobByReference '1000004', @jobId OUTPUT
EXECUTE OEE.usp_BeginJobEvent @equipmentId, @jobId, @beginTime
--SELECT * FROM OEE.Jobs
--SELECT * FROM OEE.JobEvents

-- Test usp_BeginShiftEvent
--DECLARE @beginTime datetime = SYSUTCDATETIME()
DECLARE @shiftScheduleId int = OEE.fn_FindShiftScheduleByName ('Operations')
DECLARE @shiftId int = OEE.fn_FindShiftByName (@shiftScheduleId, 'A')
EXECUTE OEE.usp_BeginShiftEvent @shiftScheduleId, @shiftId, @beginTime
--SELECT * FROM OEE.ShiftEvents

-- Select all from EquipmentEvents, calculate Minutes
SELECT *, CONVERT(float, DATEDIFF(ms, BeginTime, ISNULL(EndTime, SYSUTCDATETIME()))) / 60000 Minutes
FROM OEE.EquipmentEvents