drop table if exists OEE.CounterEvents
go

drop table if exists OEE.Counters
go

drop table if exists OEE.EquipmentEvents
go

drop table if exists OEE.JobEvents
go

drop table if exists OEE.Jobs
go

drop table if exists OEE.PerformanceEvents
go

drop table if exists OEE.ShiftEvents
go

drop table if exists OEE.Shifts
go

drop table if exists OEE.ShiftSchedules
go

drop table if exists OEE.StateEvents
go

drop table if exists OEE.Equipment
go

drop table if exists OEE.StateReasons
go

drop table if exists OEE.States
go

drop table if exists OEE.StateClasses
go

drop function if exists OEE.fn_FindEquipmentByPath
go

drop function if exists OEE.fn_FindEquipmentStateByName
go

drop function if exists OEE.fn_FindEquipmentStateByValue
go

drop function if exists OEE.fn_FindJobByReference
go

drop function if exists OEE.fn_FindLastEquipmentEvent
go

drop function if exists OEE.fn_FindLastJobEvent
go

drop function if exists OEE.fn_FindLastShiftEvent
go

drop function if exists OEE.fn_FindLastStateEvent
go

drop function if exists OEE.fn_FindShiftByName
go

drop function if exists OEE.fn_FindShiftScheduleByName
go

drop procedure if exists OEE.usp_BeginEquipmentEvent
go

drop procedure if exists OEE.usp_BeginJobEvent
go

drop procedure if exists OEE.usp_BeginShiftEvent
go

drop procedure if exists OEE.usp_BeginStateEvent
go

drop procedure if exists OEE.usp_FindOrCreateJobByReference
go


