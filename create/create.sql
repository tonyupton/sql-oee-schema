create table oee.Jobs
(
	Id int identity,
	Reference varchar(50) not null,
	constraint Jobs_pk
		primary key (Id),
	constraint Jobs_pk_2
		unique (Id)
)
go

create table oee.JobEvents
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
		foreign key (JobId) references oee.Jobs
)
go

create table oee.ShiftSchedules
(
	Id int identity,
	Name varchar(50) not null,
	constraint ShiftSchedules_pk
		primary key (Id),
	constraint ShiftSchedules_pk_2
		unique (Name)
)
go

create table oee.Shifts
(
	Id int identity,
	Name varchar(50) not null,
	ScheduleId int,
	constraint Shifts_pk
		primary key (Id),
	constraint Shifts_pk_2
		unique (ScheduleId, Name),
	constraint Shifts_ShiftSchedules_Id_fk
		foreign key (ScheduleId) references oee.ShiftSchedules
)
go

create table oee.ShiftEvents
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
		foreign key (ShiftScheduleId) references oee.ShiftSchedules,
	constraint ShiftEvents_Shifts_Id_fk
		foreign key (ShiftId) references oee.Shifts
)
go

create table oee.StateClasses
(
	Id int identity,
	Name varchar(50) not null,
	constraint StateClasses_pk
		primary key (Id),
	constraint StateClasses_pk_2
		unique (Name)
)
go

create table oee.Equipment
(
	Id int identity,
	Site varchar(50) not null,
	Area varchar(50) not null,
	Line varchar(50) not null,
	Cell varchar(50),
	Description varchar(255),
	ShiftScheduleId int,
	StateClassId int,
	constraint Equipment_pk
		primary key (Id),
	constraint Equipment_pk_2
		unique (Site, Area, Line, Cell),
	constraint Equipment_StateClasses_Id_fk
		foreign key (StateClassId) references oee.StateClasses
)
go

create table oee.PerformanceEvents
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
		foreign key (EquipmentId) references oee.Equipment
)
go

create table oee.States
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
		foreign key (StateClassId) references oee.StateClasses
)
go

create table oee.StateReasons
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
		foreign key (StateId) references oee.States,
)
go

create table oee.StateEvents
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
		foreign key (EquipmentId) references oee.Equipment,
	constraint StateEvents_StateReasons_Id_fk
		foreign key (ReasonId) references oee.StateReasons,
	constraint StateEvents_States_Id_fk
		foreign key (StateId) references oee.States
)
go

create table oee.EquipmentEvents
(
	Id bigint identity,
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
		foreign key (EquipmentId) references oee.Equipment,
	constraint EquipmentEvents_JobEvents_Id_fk
		foreign key (JobEventId) references oee.JobEvents,
	constraint EquipmentEvents_PerformanceEvents_Id_fk
		foreign key (PerformanceEventId) references oee.PerformanceEvents,
	constraint EquipmentEvents_ShiftEvents_Id_fk
		foreign key (ShiftEventId) references oee.ShiftEvents,
	constraint EquipmentEvents_StateEvents_Id_fk
		foreign key (StateEventId) references oee.StateEvents
)
go

CREATE FUNCTION [oee].[fn_FindEquipmentByPath] 
(
	@path varchar(255)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.Equipment e
	WHERE CONCAT(e.Site,'/',e.Area,'/',e.Line) = @path

	RETURN @id
END
go

CREATE FUNCTION [oee].[fn_FindEquipmentStateByName]
(
	@equipmentId int,
	@stateName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = S.Id
	FROM oee.Equipment
	INNER JOIN oee.StateClasses SC on SC.Id = Equipment.StateClassId
	INNER JOIN oee.States S on SC.Id = S.StateClassId
	WHERE Equipment.Id = @equipmentId
	AND S.Name = @stateName

	RETURN @id
END
go

CREATE FUNCTION [oee].[fn_FindEquipmentStateByValue]
(
	@equipmentId int,
	@stateValue int
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = S.Id
	FROM oee.Equipment
	INNER JOIN oee.StateClasses SC on SC.Id = Equipment.StateClassId
	INNER JOIN oee.States S on SC.Id = S.StateClassId
	WHERE Equipment.Id = @equipmentId
	AND S.Value = @stateValue

	RETURN @id
END
go

CREATE FUNCTION [oee].[fn_FindJobByReference] 
(
	@reference varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.Jobs
	WHERE Reference = @reference

	RETURN @id
END
go

CREATE FUNCTION [oee].[fn_FindLastEquipmentEvent]
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

CREATE FUNCTION [oee].[fn_FindShiftByName]
(
	@scheduleId int,
	@shiftName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.Shifts
	WHERE ScheduleId = @scheduleId AND Name = @shiftName

	RETURN @id
END
go

CREATE FUNCTION [oee].[fn_FindShiftScheduleByName]
(
	@scheduleName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.ShiftSchedules
	WHERE Name = @scheduleName

	RETURN @id
END
go

CREATE PROCEDURE [oee].[usp_BeginEquipmentEvent] (
	@equipmentId int,
	@beginTime datetime = NULL,
    @eventId int = NULL OUTPUT
)
AS
BEGIN

    -- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME()

    DECLARE @lastEventId int = oee.fn_FindLastEquipmentEvent(@equipmentId, @beginTime)

    DECLARE @lastEventTime datetime = (SELECT BeginTime FROM oee.EquipmentEvents WHERE Id = @lastEventId)

    IF @lastEventTime > @beginTime RETURN

    IF @lastEventTime = @beginTime
    BEGIN
        SET @eventId = @lastEventId
        RETURN
    END

    IF @lastEventId IS NOT NULL
    BEGIN
        UPDATE oee.EquipmentEvents
        SET EndTime = @beginTime
        WHERE Id = @lastEventId
    END

    INSERT INTO oee.EquipmentEvents
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

CREATE PROCEDURE [oee].[usp_BeginJobEvent] (
	@equipmentId int,
	@jobId int,
	@beginTime datetime = NULL,
    @jobEventId int = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	SET @jobEventId = NULL

	-- Validate parameters
	IF @equipmentId IS NULL RETURN
	IF @jobId IS NULL RETURN

	-- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME ( )

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
	FROM oee.JobEvents JE
	WHERE JE.EquipmentId = @equipmentId
	ORDER BY BeginTime DESC

	-- Terminate previous Job Event
	IF @lastJobId IS NOT NULL
            AND @jobId != ISNULL(@lastJobId, -1)
            AND @lastJobEventBeginTime < @beginTime
            AND @lastJobEventEndTime IS NULL
    BEGIN
        UPDATE oee.JobEvents
        SET EndTime = @beginTime
        WHERE Id = @lastJobEventId
    END

    -- Insert new Job Event
	IF @lastJobId IS NULL
	        OR ( @jobId != ISNULL(@lastJobId, -1)
	        AND @lastJobEventBeginTime < @beginTime)
    BEGIN
        INSERT INTO oee.JobEvents (EquipmentId, JobId, BeginTime)
        VALUES (@equipmentId, @jobId, @beginTime)
        SET @jobEventId = SCOPE_IDENTITY()
    END

    -- If no new Job Event was inserted then return
    IF @jobEventId IS NULL RETURN

	DECLARE @newEquipmentEventId int
	EXECUTE oee.usp_BeginEquipmentEvent
            @equipmentId,
            @beginTime,
            @newEquipmentEventId OUTPUT

    UPDATE oee.EquipmentEvents
    SET JobEventId = @jobEventId
    WHERE Id = @newEquipmentEventId

END
go

CREATE PROCEDURE [oee].[usp_BeginShiftEvent] (
	@shiftScheduleId int,
	@shiftId int,
	@timestamp datetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @timestamp IS NULL SET @timestamp = SYSUTCDATETIME ( )

	DECLARE @currentShiftEventId int, @currentShiftId int

	SELECT TOP (1)
		@currentShiftEventId = events.Id,
		@currentShiftId = events.ShiftId
	FROM oee.ShiftEvents events
	WHERE events.ShiftScheduleId = @shiftScheduleId
	ORDER BY events.BeginTime DESC

	IF @currentShiftId != @shiftId OR @currentShiftId IS NULL OR @shiftId IS NULL
	BEGIN

		UPDATE oee.ShiftEvents
			SET EndTime = @timestamp
		FROM oee.ShiftEvents events
		WHERE events.Id = @currentShiftEventId

		DECLARE @insertedShiftEvents TABLE (
			ShiftScheduleId int,
			ShiftEventId int,
			ShiftId int, BeginTime
			datetime
		)

		INSERT INTO oee.ShiftEvents (ShiftScheduleId, ShiftId, BeginTime)
		OUTPUT inserted.ShiftScheduleId, inserted.Id, inserted.ShiftId, inserted.BeginTime
		INTO @insertedShiftEvents
		SELECT @shiftScheduleId, @shiftId, @timestamp

		DECLARE @equipment TABLE (
			EquipmentId int,
			EquipmentEventId int
		)

		INSERT INTO @equipment
		SELECT
			equipment.Id EquipmentId,
			(SELECT TOP(1) Id FROM oee.EquipmentEvents WHERE EquipmentId = equipment.Id AND BeginTime < shiftEvents.BeginTime ORDER BY BeginTime DESC) EquipmentEventId
		FROM @insertedShiftEvents shiftEvents
		INNER JOIN oee.Equipment equipment ON equipment.ShiftScheduleId = shiftEvents.ShiftScheduleId

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
		LEFT JOIN oee.EquipmentEvents events ON events.Id = equipment.EquipmentEventId

		-- UPDATE ShiftEventId in EquipmentEvents where BeginTime = @timestamp
		UPDATE oee.EquipmentEvents
		SET ShiftEventId = shiftEvents.ShiftEventId
		FROM oee.EquipmentEvents events
		INNER JOIN @equipment equipment ON equipment.EquipmentEventId = events.Id
		CROSS JOIN @insertedShiftEvents shiftEvents
		WHERE events.Id = equipment.EquipmentEventId AND events.BeginTime = @timestamp

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
		UPDATE oee.EquipmentEvents
		SET EndTime = @timestamp
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
		FROM oee.EquipmentEvents events
		INNER JOIN @equipment equipment ON equipment.EquipmentEventId = events.Id
		WHERE events.Id = equipment.EquipmentEventId AND events.BeginTime < @timestamp

		-- INSERT new EquipmentEvents where previous events have been terminated
		INSERT INTO oee.EquipmentEvents (
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
		INSERT INTO oee.EquipmentEvents (
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
			@timestamp
		FROM @equipment E
		CROSS JOIN @insertedShiftEvents shiftEvents
	    WHERE E.EquipmentEventId IS NULL
	END
END
go

CREATE PROCEDURE [oee].[usp_BeginStateEvent] (
	@equipmentId int,
	@stateId int,
	@beginTime datetime = NULL,
    @stateEventId int = NULL OUTPUT,
    @equipmentEventId int = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME()

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
	FROM oee.StateEvents
	WHERE EquipmentId = @equipmentId 
	AND BeginTime <= @beginTime
	AND (EndTime IS NULL OR EndTime > @beginTime)
	ORDER BY BeginTime DESC

	IF @lastStateEventBeginTime = @beginTime
	BEGIN
		--Update StateId if BeginTime = @timestamp
		UPDATE oee.StateEvents
			SET StateId = @stateId
		WHERE Id = @lastStateEventId
	END
	ELSE IF @lastStateId != @stateId OR @lastStateId IS NULL
	BEGIN
		--Terminate current EquipmentStateEvent
		UPDATE oee.StateEvents
			SET EndTime = @beginTime
		WHERE Id = @lastStateEventId

		--INSERT new State Event
		INSERT INTO oee.StateEvents (
			EquipmentId,
			BeginTime,
			StateId
		)
		VALUES (
			@equipmentId,
			@beginTime,
			@stateId
		)
		DECLARE @insertedStateEventId int = SCOPE_IDENTITY()

		--Declare table variable to hold current EquipmentEvent
		DECLARE @currentEquipmentEvents TABLE (
			Id int,
			EquipmentId int,
			StateEventId int,
			JobEventId int,
			ShiftEventId int,
			PerformanceEventId int,
			BeginTime datetime,
			EndTime datetime
		)
		--SELECT current EquipmentEvent
		INSERT INTO @currentEquipmentEvents
		SELECT TOP (1)
			events.Id,
			events.EquipmentId,
			events.StateEventId,
			events.JobEventId,
			events.ShiftEventId,
			events.PerformanceEventId,
			events.BeginTime,
			events.EndTime
		FROM oee.EquipmentEvents events
		WHERE events.EquipmentId = @equipmentId
		AND events.BeginTime <= @beginTime
		ORDER BY events.BeginTime DESC

		DECLARE @currentEquipmentEventId int = (SELECT Id FROM @currentEquipmentEvents)

		-- UPDATE StateEventId in EquipmentEvents where BeginTime = @timestamp
		UPDATE oee.EquipmentEvents
		SET StateEventId = @insertedStateEventId
		FROM oee.EquipmentEvents events
		WHERE events.Id = @currentEquipmentEventId AND events.BeginTime = @beginTime

		--Declare table variable to hold terminated EquipmentEvents
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
		UPDATE oee.EquipmentEvents
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
		FROM oee.EquipmentEvents events
		WHERE events.Id = @currentEquipmentEventId AND events.BeginTime < @beginTime

		-- INSERT new EquipmentEvents where previous events have been terminated
		INSERT INTO oee.EquipmentEvents (
			EquipmentId,
			StateEventId,
			JobEventId,
			ShiftEventId,
			PerformanceEventId,
			BeginTime
		)
		SELECT
			equipmentEvents.EquipmentId,
			@insertedStateEventId,
			equipmentEvents.JobEventId,
			equipmentEvents.ShiftEventId,
			equipmentEvents.PerformanceEventId,
			@beginTime
		FROM @terminatedEquipmentEvents equipmentEvents


	    SET @stateEventId =  @insertedStateEventId
	    SET @equipmentEventId = SCOPE_IDENTITY()
	END
END
go

CREATE PROCEDURE [oee].[usp_FindOrCreateJobByReference] (
	@reference varchar(50),
	@id int OUTPUT
)
AS
BEGIN
	SELECT @id = Id
	FROM oee.Jobs
	WHERE Reference = @reference

	IF @id IS NULL
	BEGIN
		INSERT INTO oee.Jobs (Reference)
		VALUES (@reference)
		SET @reference = SCOPE_IDENTITY ( )
	END
END
go


