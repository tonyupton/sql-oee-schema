DECLARE @timestamp datetime = '2024-01-28 21:32:03.927'
DECLARE @shiftScheduleId int = oee.fn_FindShiftScheduleByName ('Operations')
DECLARE @shiftId int = oee.fn_FindShiftByName (@shiftScheduleId, 'B')
DECLARE @equipmentId int = oee.fn_FindEquipmentByPath ('Site/Area/Line 1')
DECLARE @stateId int = oee.fn_FindEquipmentStateByValue (@equipmentId, 0)
DECLARE @jobId int
EXECUTE oee.usp_FindOrCreateJobByReference '1000002', @jobId OUTPUT
EXECUTE oee.usp_StartJobEvent @equipmentId, @jobId
SELECT * FROM oee.Jobs
SELECT * FROM oee.JobEvents

/*
EXECUTE oee.usp_InsertShiftEvent @shiftScheduleId, @shiftId
SELECT * FROM oee.ShiftEvents
*/

EXECUTE oee.usp_InsertStateEvent @equipmentId, @stateId

SELECT *,
    CONVERT(float, DATEDIFF(ms, BeginTime, ISNULL(EndTime, SYSUTCDATETIME()))) / 60000 Minutes
FROM oee.EquipmentEvents
