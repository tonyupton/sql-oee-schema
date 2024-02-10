create table OEE.Jobs
(
	Id int identity,
	Reference varchar(50) not null,
	constraint Jobs_pk
		primary key (Id),
	constraint Jobs_pk_2
		unique (Id)
)
go

create table OEE.JobEvents
(
	Id int identity,
	EquipmentId int not null,
	JobId int not null,
	BeginTime datetime not null,
	EndTime datetime,
	constraint JobEvents_pk
		primary key (Id),
	constraint JobEvents_pk_2
		unique (EquipmentId, BeginTime),
	constraint JobEvents_Jobs_Id_fk
		foreign key (JobId) references OEE.Jobs
)
go

create table OEE.ShiftSchedules
(
	Id int identity,
	Name varchar(50) not null,
	constraint ShiftSchedules_pk
		primary key (Id),
	constraint ShiftSchedules_pk_2
		unique (Name)
)
go

create table OEE.Shifts
(
	Id int identity,
	Name varchar(50) not null,
	ScheduleId int,
	constraint Shifts_pk
		primary key (Id),
	constraint Shifts_pk_2
		unique (ScheduleId, Name),
	constraint Shifts_ShiftSchedules_Id_fk
		foreign key (ScheduleId) references OEE.ShiftSchedules
)
go

create table OEE.ShiftEvents
(
	Id int identity,
	ShiftScheduleId int not null,
	ShiftId int not null,
	BeginTime datetime not null,
	EndTime datetime,
	constraint ShiftEvents_pk
		primary key (Id),
	constraint ShiftEvents_pk_2
		unique (BeginTime, ShiftScheduleId),
	constraint ShiftEvents_ShiftSchedules_Id_fk
		foreign key (ShiftScheduleId) references OEE.ShiftSchedules,
	constraint ShiftEvents_Shifts_Id_fk
		foreign key (ShiftId) references OEE.Shifts
)
go

create table OEE.StateClasses
(
	Id int identity,
	Name varchar(50) not null,
	constraint StateClasses_pk
		primary key (Id),
	constraint StateClasses_pk_2
		unique (Name)
)
go

create table OEE.Equipment
(
	Id int identity,
	Enterprise varchar(50) not null,
	Site varchar(50) not null,
	Area varchar(50) not null,
	Line varchar(50) not null,
	Cell varchar(50),
	Description varchar(255),
	ShiftScheduleId int,
	StateClassId int,
	Path as concat([Enterprise], '/', [Site], '/', [Area], '/', [Line], IIF([Cell] IS NULL, '', concat('/', [Cell]))),
	constraint Equipment_pk
		primary key (Id),
	constraint Equipment_pk_2
		unique (Path),
	constraint Equipment_StateClasses_Id_fk
		foreign key (StateClassId) references OEE.StateClasses
)
go

create table OEE.Counters
(
	Id int identity,
	EquipmentId int not null,
	Name int not null,
	Type int not null,
	Mode int not null,
	Value int,
	constraint Counters_pk
		primary key (Id),
	constraint Counters_pk_2
		unique (EquipmentId, Name),
	constraint Counters_Equipment_Id_fk
		foreign key (EquipmentId) references OEE.Equipment
)
go

create table OEE.PerformanceEvents
(
	Id int identity,
	EquipmentId int not null,
	IdealRate float,
	ScheduleRate float,
	BeginTime datetime not null,
	EndTime datetime,
	constraint PerformanceEvents_pk
		primary key (Id),
	constraint PerformanceEvents_pk_2
		unique (BeginTime, EquipmentId),
	constraint PerformanceEvents_Equipment_Id_fk
		foreign key (EquipmentId) references OEE.Equipment
)
go

create table OEE.States
(
	Id int identity,
	StateClassId int not null,
	Name varchar(50) not null,
	Value int not null,
	Running bit,
	Slow bit not null,
	Waste bit not null,
	Recordable bit not null,
	constraint States_pk
		primary key (Id),
	constraint States_pk_2
		unique (StateClassId, Name),
	constraint States_pk_3
		unique (StateClassId, Value),
	constraint States_StateClasses_Id_fk
		foreign key (StateClassId) references OEE.StateClasses
)
go

create table OEE.StateReasons
(
	Id int identity,
	StateId int not null,
	Name varchar(50) not null,
	Category varchar(50),
	Scheduled bit default 0 not null,
	constraint StateReasons_pk
		primary key (Id),
	constraint StateReasons_pk_2
		unique (StateId, Category, Name),
	constraint StateReasons_States_Id_fk
		foreign key (StateId) references OEE.States,
)
go

create table OEE.StateEvents
(
	Id int identity,
	EquipmentId int not null,
	BeginTime datetime not null,
	EndTime datetime,
	StateId int,
	ReasonId int,
	ReasonComment varchar(2000),
	constraint StateEvents_pk
		primary key (Id),
	constraint StateEvents_pk_2
		unique (BeginTime, EquipmentId),
	constraint StateEvents_Equipment_Id_fk
		foreign key (EquipmentId) references OEE.Equipment,
	constraint StateEvents_StateReasons_Id_fk
		foreign key (ReasonId) references OEE.StateReasons,
	constraint StateEvents_States_Id_fk
		foreign key (StateId) references OEE.States
)
go

create table OEE.EquipmentEvents
(
	Id int identity,
	EquipmentId int not null,
	StateEventId int,
	JobEventId int,
	ShiftEventId int,
	PerformanceEventId int,
	BeginTime datetime not null,
	EndTime datetime,
	constraint EquipmentEvents_pk
		primary key (Id),
	constraint EquipmentEvents_uk
		unique (EquipmentId, BeginTime),
	constraint EquipmentEvents_Equipment_Id_fk
		foreign key (EquipmentId) references OEE.Equipment,
	constraint EquipmentEvents_JobEvents_Id_fk
		foreign key (JobEventId) references OEE.JobEvents,
	constraint EquipmentEvents_PerformanceEvents_Id_fk
		foreign key (PerformanceEventId) references OEE.PerformanceEvents,
	constraint EquipmentEvents_ShiftEvents_Id_fk
		foreign key (ShiftEventId) references OEE.ShiftEvents,
	constraint EquipmentEvents_StateEvents_Id_fk
		foreign key (StateEventId) references OEE.StateEvents
)
go

create table OEE.CounterEvents
(
	Id int identity,
	EquipmentEventId int not null,
	CounterId int not null,
	BeginValue int,
	EndValue int,
	DeltaValue int,
	constraint CounterEvents_pk
		primary key (Id),
	constraint CounterEvents_pk_2
		unique (EquipmentEventId, CounterId),
	constraint CounterEvents_Counters_Id_fk
		foreign key (CounterId) references OEE.Counters,
	constraint CounterEvents_EquipmentEvents_Id_fk
		foreign key (EquipmentEventId) references OEE.EquipmentEvents
)
go

CREATE FUNCTION [OEE].[fn_FindEquipmentByPath]
(
	@path varchar(255)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM OEE.Equipment e
	WHERE e.Path = @path

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindEquipmentStateByName]
(
	@equipmentId int,
	@stateName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = S.Id
	FROM OEE.Equipment
	INNER JOIN OEE.StateClasses SC on SC.Id = Equipment.StateClassId
	INNER JOIN OEE.States S on SC.Id = S.StateClassId
	WHERE Equipment.Id = @equipmentId
	AND S.Name = @stateName

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindEquipmentStateByValue]
(
	@equipmentId int,
	@stateValue int
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = S.Id
	FROM OEE.Equipment
	INNER JOIN OEE.StateClasses SC on SC.Id = Equipment.StateClassId
	INNER JOIN OEE.States S on SC.Id = S.StateClassId
	WHERE Equipment.Id = @equipmentId
	AND S.Value = @stateValue

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindJobByReference]
(
	@reference varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM OEE.Jobs
	WHERE Reference = @reference

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindLastEquipmentEvent]
(
	@equipmentId int,
    @beginTime datetime = NULL
)
RETURNS int
AS
BEGIN
	DECLARE @id int

    -- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME ( )

	SELECT TOP (1)
        @id = Id
	FROM EquipmentEvents
	WHERE EquipmentId = @equipmentId
	AND BeginTime <= @beginTime
	ORDER BY BeginTime DESC

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindLastJobEvent]
(
	@equipmentId int,
    @beginTime datetime = NULL
)
RETURNS int
AS
BEGIN
	DECLARE @id int

    -- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME ( )

	SELECT TOP (1)
        @id = Id
	FROM JobEvents
	WHERE EquipmentId = @equipmentId
	AND BeginTime <= @beginTime
	ORDER BY BeginTime DESC

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindLastShiftEvent]
(
	@shiftScheduleId int,
    @beginTime datetime = NULL
)
RETURNS int
AS
BEGIN
	DECLARE @id int

    -- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME ( )

	SELECT TOP (1)
        @id = Id
	FROM ShiftEvents
	WHERE ShiftScheduleId = @shiftScheduleId
	AND BeginTime <= @beginTime
	ORDER BY BeginTime DESC

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindLastStateEvent]
(
	@equipmentId int,
    @beginTime datetime = NULL
)
RETURNS int
AS
BEGIN
	DECLARE @id int

    -- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME ( )

	SELECT TOP (1)
        @id = Id
	FROM StateEvents
	WHERE EquipmentId = @equipmentId
	AND BeginTime <= @beginTime
	ORDER BY BeginTime DESC

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindShiftByName]
(
	@scheduleId int,
	@shiftName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM OEE.Shifts
	WHERE ScheduleId = @scheduleId AND Name = @shiftName

	RETURN @id
END
go

CREATE FUNCTION [OEE].[fn_FindShiftScheduleByName]
(
	@scheduleName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM OEE.ShiftSchedules
	WHERE Name = @scheduleName

	RETURN @id
END
go

CREATE PROCEDURE [OEE].[usp_BeginEquipmentEvent] (
	@equipmentId int,
	@beginTime datetime = NULL,
    @eventId int = NULL OUTPUT
)
AS
BEGIN

    -- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME()

    DECLARE @lastEventId int = OEE.fn_FindLastEquipmentEvent(@equipmentId, @beginTime)

    DECLARE @lastEventTime datetime = (SELECT BeginTime FROM OEE.EquipmentEvents WHERE Id = @lastEventId)

    IF @lastEventTime > @beginTime RETURN

    IF @lastEventTime = @beginTime
    BEGIN
        SET @eventId = @lastEventId
        RETURN
    END

    IF @lastEventId IS NOT NULL
    BEGIN
        UPDATE OEE.EquipmentEvents
        SET EndTime = @beginTime
        WHERE Id = @lastEventId
    END

    INSERT INTO OEE.EquipmentEvents
    (EquipmentId, StateEventId, JobEventId, ShiftEventId, PerformanceEventId, BeginTime)
    SELECT TOP (1)
        @equipmentId,
        StateEventId,
        JobEventId,
        ShiftEventId,
        PerformanceEventId,
        @beginTime
	FROM EquipmentEvents
	WHERE EquipmentId = @equipmentId
    AND Id = @lastEventId

    SET @eventId = SCOPE_IDENTITY()
END
go

CREATE PROCEDURE [OEE].[usp_BeginJobEvent] (
	@equipmentId int,
	@jobId int,
	@beginTime datetime = NULL,
    @jobEventId int = NULL OUTPUT,
    @equipmentEventId int = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Validate parameters
	IF @equipmentId IS NULL RETURN
	IF @jobId IS NULL RETURN

	-- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME ( )
	SET @jobEventId = NULL
	SET @equipmentEventId = NULL

	-- Find the last record for Job Events for given equipment
	DECLARE @lastJobEventId int
	DECLARE @lastJobId int
	DECLARE @lastJobEventBeginTime datetime
	DECLARE @lastJobEventEndTime datetime
	SELECT TOP (1)
	    @lastJobEventId = JE.Id,
	    @lastJobId = JE.JobId,
	    @lastJobEventBeginTime = JE.BeginTime,
	    @lastJobEventEndTime = JE.EndTime
	FROM OEE.JobEvents JE
	WHERE JE.EquipmentId = @equipmentId
	ORDER BY BeginTime DESC

	-- Terminate previous Job Event
	IF @lastJobEventId IS NOT NULL
            AND @jobId != ISNULL(@lastJobId, -1)
            AND @lastJobEventBeginTime < @beginTime
            AND @lastJobEventEndTime IS NULL
    BEGIN
        UPDATE OEE.JobEvents
        SET EndTime = @beginTime
        WHERE Id = @lastJobEventId
    END

    -- Insert new Job Event
	IF @lastJobEventId IS NULL
	        OR ( @jobId != ISNULL(@lastJobId, -1)
	        AND @lastJobEventBeginTime < @beginTime)
    BEGIN
        INSERT INTO OEE.JobEvents (EquipmentId, JobId, BeginTime)
        VALUES (@equipmentId, @jobId, @beginTime)
        SET @jobEventId = SCOPE_IDENTITY()
    END

    -- If no new Job Event was inserted then return
    IF @jobEventId IS NULL RETURN

    -- Start new Equipment Event
	EXECUTE OEE.usp_BeginEquipmentEvent
            @equipmentId,
            @beginTime,
            @equipmentEventId OUTPUT

	-- Set JobEventId on the new EquipmentEvent to the new JobEventID
    UPDATE OEE.EquipmentEvents
    SET JobEventId = @jobEventId
    WHERE Id = @equipmentEventId

END
go

CREATE PROCEDURE [OEE].[usp_BeginShiftEvent] (
	@shiftScheduleId int,
	@shiftId int,
	@beginTime datetime = NULL,
    @shiftEventId int = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME()
	SET @shiftEventId = NULL

	DECLARE @currentShiftEventId int, @currentShiftId int

	SELECT TOP (1)
		@currentShiftEventId = events.Id,
		@currentShiftId = events.ShiftId
	FROM OEE.ShiftEvents events
	WHERE events.ShiftScheduleId = @shiftScheduleId
	ORDER BY events.BeginTime DESC

	IF @currentShiftId != @shiftId OR @currentShiftId IS NULL OR @shiftId IS NULL
	BEGIN

		UPDATE OEE.ShiftEvents
			SET EndTime = @beginTime
		FROM OEE.ShiftEvents events
		WHERE events.Id = @currentShiftEventId

		DECLARE @insertedShiftEvents TABLE (
			ShiftScheduleId int,
			ShiftEventId int,
			ShiftId int, BeginTime
			datetime
		)

		INSERT INTO OEE.ShiftEvents (ShiftScheduleId, ShiftId, BeginTime)
		OUTPUT inserted.ShiftScheduleId, inserted.Id, inserted.ShiftId, inserted.BeginTime
		INTO @insertedShiftEvents
		SELECT @shiftScheduleId, @shiftId, @beginTime

		SET @shiftEventId = (SELECT ShiftEventId FROM @insertedShiftEvents)

		DECLARE @equipment TABLE (
			EquipmentId int,
			EquipmentEventId int
		)

		INSERT INTO @equipment
		SELECT
			equipment.Id EquipmentId,
			(SELECT TOP(1) Id FROM OEE.EquipmentEvents WHERE EquipmentId = equipment.Id AND BeginTime < shiftEvents.BeginTime ORDER BY BeginTime DESC) EquipmentEventId
		FROM @insertedShiftEvents shiftEvents
		INNER JOIN OEE.Equipment equipment ON equipment.ShiftScheduleId = shiftEvents.ShiftScheduleId

		DECLARE @equipmentEvents TABLE (
			EquipmentEventId int,
			EquipmentId int,
			StateEventId int,
			JobEventId int,
			PerformanceEventId int,
			ShiftEventId int,
			BeginTime datetime,
			EndTime datetime
		)

		INSERT INTO @equipmentEvents (
			EquipmentId,
			EquipmentEventId,
			StateEventId,
			JobEventId,
			ShiftEventId,
			PerformanceEventId,
			BeginTime,
			EndTime
		)
		SELECT
			equipment.EquipmentId,
			equipment.EquipmentEventId,
			events.StateEventId,
			events.JobEventId,
			events.ShiftEventId,
			events.PerformanceEventId,
			events.BeginTime,
			events.EndTime
		FROM @equipment equipment
		LEFT JOIN OEE.EquipmentEvents events ON events.Id = equipment.EquipmentEventId

		-- UPDATE ShiftEventId in EquipmentEvents where BeginTime = @timestamp
		UPDATE OEE.EquipmentEvents
		SET ShiftEventId = shiftEvents.ShiftEventId
		FROM OEE.EquipmentEvents events
		INNER JOIN @equipment equipment ON equipment.EquipmentEventId = events.Id
		CROSS JOIN @insertedShiftEvents shiftEvents
		WHERE events.Id = equipment.EquipmentEventId AND events.BeginTime = @beginTime

		DECLARE @terminatedEquipmentEvents TABLE (
			EquipmentEventId int,
			EquipmentId int,
			StateEventId int,
			JobEventId int,
			PerformanceEventId int,
			ShiftEventId int,
			BeginTime datetime,
			EndTime datetime
		)

		-- UPDATE EndTime to terminate EquipmentEvents where BeginTime < @timestamp
		UPDATE OEE.EquipmentEvents
		SET EndTime = @beginTime
		OUTPUT
			inserted.EquipmentId,
			inserted.Id,
			inserted.StateEventId,
			inserted.JobEventId,
			inserted.ShiftEventId,
			inserted.PerformanceEventId,
			inserted.BeginTime,
			inserted.EndTime
		INTO @terminatedEquipmentEvents (
			EquipmentId,
			EquipmentEventId,
			StateEventId,
			JobEventId,
			ShiftEventId,
			PerformanceEventId,
			BeginTime,
			EndTime
		)
		FROM OEE.EquipmentEvents events
		INNER JOIN @equipment equipment ON equipment.EquipmentEventId = events.Id
		WHERE events.Id = equipment.EquipmentEventId AND events.BeginTime < @beginTime

		-- INSERT new EquipmentEvents where previous events have been terminated
		INSERT INTO OEE.EquipmentEvents (
			EquipmentId,
			StateEventId,
			JobEventId,
			ShiftEventId,
			PerformanceEventId,
			BeginTime
		)
		SELECT
			equipmentEvents.EquipmentId,
			equipmentEvents.StateEventId,
			equipmentEvents.JobEventId,
			shiftEvents.ShiftEventId,
			equipmentEvents.PerformanceEventId,
			shiftEvents.BeginTime
		FROM @terminatedEquipmentEvents equipmentEvents
		CROSS JOIN @insertedShiftEvents shiftEvents

	    -- INSERT new EquipmentEvents where EquipmentEventId is NULL
		INSERT INTO OEE.EquipmentEvents (
			EquipmentId,
			StateEventId,
			JobEventId,
			ShiftEventId,
			PerformanceEventId,
			BeginTime
		)
		SELECT
			E.EquipmentId,
			NULL,
			NULL,
			shiftEvents.ShiftEventId,
			NULL,
			@beginTime
		FROM @equipment E
		CROSS JOIN @insertedShiftEvents shiftEvents
	    WHERE E.EquipmentEventId IS NULL
	END
END
go

CREATE PROCEDURE [OEE].[usp_BeginStateEvent] (
	@equipmentId int,
	@stateId int,
	@beginTime datetime = NULL,
    @stateEventId int = NULL OUTPUT,
    @equipmentEventId int = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Validate parameters
	IF @equipmentId IS NULL RETURN
	IF @stateId IS NULL RETURN

	-- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME()
	SET @stateEventId = NULL
	SET @equipmentEventId = NULL

    -- Find the last recorded State Event for given equipment
	DECLARE @lastStateEventId int
	DECLARE @lastStateId int
	DECLARE @lastStateEventBeginTime datetime
	DECLARE @lastStateEventEndTime datetime
	SELECT TOP (1)
		@lastStateEventId = Id,
		@lastStateId = StateId,
		@lastStateEventBeginTime = BeginTime,
		@lastStateEventEndTime = EndTime
	FROM OEE.StateEvents
	WHERE EquipmentId = @equipmentId
	AND BeginTime <= @beginTime
	AND (EndTime IS NULL OR EndTime > @beginTime)
	ORDER BY BeginTime DESC


	-- Terminate previous State Event
	IF @lastStateEventId IS NOT NULL
            AND @stateId != ISNULL(@lastStateId, -1)
            AND @lastStateEventBeginTime < @beginTime
            AND @lastStateEventEndTime IS NULL
    BEGIN
        UPDATE OEE.StateEvents
        SET EndTime = @beginTime
        WHERE Id = @lastStateEventId
    END

    -- Insert new State Event
	IF @lastStateEventId IS NULL
	        OR ( @stateId != ISNULL(@lastStateId, -1)
	        AND @lastStateEventBeginTime < @beginTime)
    BEGIN
        INSERT INTO OEE.StateEvents (EquipmentId, StateId, BeginTime)
        VALUES (@equipmentId, @stateId, @beginTime)
        SET @stateEventId = SCOPE_IDENTITY()
    END


	-- If no new State Event was inserted then return
    IF @stateEventId IS NULL RETURN

	-- Start new Equipment Event
	EXECUTE OEE.usp_BeginEquipmentEvent
            @equipmentId,
            @beginTime,
            @equipmentEventId OUTPUT

	-- Set StateEventId on the new EquipmentEvent to the new StateEventID
    UPDATE OEE.EquipmentEvents
    SET StateEventId = @stateEventId
    WHERE Id = @equipmentEventId
END
go


CREATE PROCEDURE [OEE].[usp_FindOrCreateJobByReference] (
	@reference varchar(50),
	@id int OUTPUT
)
AS
BEGIN
	SELECT @id = Id
	FROM OEE.Jobs
	WHERE Reference = @reference

	IF @id IS NULL
	BEGIN
		INSERT INTO OEE.Jobs (Reference)
		VALUES (@reference)
		SET @reference = SCOPE_IDENTITY ( )
	END
END
go


