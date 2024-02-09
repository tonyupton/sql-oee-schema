drop table if exists oee.CounterEvents
go

drop table if exists oee.Counters
go

drop table if exists oee.EquipmentEvents
go

drop table if exists oee.JobEvents
go

drop table if exists oee.Jobs
go

drop table if exists oee.PerformanceEvents
go

drop table if exists oee.ShiftEvents
go

drop table if exists oee.Shifts
go

drop table if exists oee.ShiftSchedules
go

drop table if exists oee.StateEvents
go

drop table if exists oee.Equipment
go

drop table if exists oee.StateReasons
go

drop table if exists oee.States
go

drop table if exists oee.StateClasses
go

drop function if exists oee.fn_FindEquipmentByPath
go

drop function if exists oee.fn_FindEquipmentStateByName
go

drop function if exists oee.fn_FindEquipmentStateByValue
go

drop function if exists oee.fn_FindJobByReference
go

drop function if exists oee.fn_FindLastEquipmentEvent
go

drop function if exists oee.fn_FindLastJobEvent
go

drop function if exists oee.fn_FindLastShiftEvent
go

drop function if exists oee.fn_FindLastStateEvent
go

drop function if exists oee.fn_FindShiftByName
go

drop function if exists oee.fn_FindShiftScheduleByName
go

drop procedure if exists oee.usp_BeginEquipmentEvent
go

drop procedure if exists oee.usp_BeginJobEvent
go

drop procedure if exists oee.usp_BeginShiftEvent
go

drop procedure if exists oee.usp_BeginStateEvent
go

drop procedure if exists oee.usp_FindOrCreateJobByReference
go


