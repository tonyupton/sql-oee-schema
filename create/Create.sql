CREATE TABLE OEE.Jobs (
	Id int IDENTITY,
	Reference varchar(50) NOT NULL,
	CONSTRAINT Jobs_pk PRIMARY KEY (Id),
	CONSTRAINT Jobs_pk_2 UNIQUE (Id)
)
go

CREATE TABLE OEE.JobEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	JobId int          NOT NULL,
	CONSTRAINT JobEvents_pk PRIMARY KEY (Id),
	CONSTRAINT JobEvents_pk_2 UNIQUE (EquipmentId, BeginTime),
	CONSTRAINT JobEvents_Jobs_Id_fk FOREIGN KEY (JobId) REFERENCES OEE.Jobs
)
go

CREATE TABLE OEE.ShiftSchedules (
	Id int IDENTITY,
	Name varchar(50) NOT NULL,
	CONSTRAINT ShiftSchedules_pk PRIMARY KEY (Id),
	CONSTRAINT ShiftSchedules_pk_2 UNIQUE (Name)
)
go

CREATE TABLE OEE.Shifts (
	Id int IDENTITY,
	Name varchar(50) NOT NULL,
	ScheduleId int,
	CONSTRAINT Shifts_pk PRIMARY KEY (Id),
	CONSTRAINT Shifts_pk_2 UNIQUE (ScheduleId, Name),
	CONSTRAINT Shifts_ShiftSchedules_Id_fk FOREIGN KEY (ScheduleId) REFERENCES OEE.ShiftSchedules
)
go

CREATE TABLE OEE.ShiftEvents (
	Id int IDENTITY,
	BeginTime datetime  NOT NULL,
	EndTime datetime,
	ShiftScheduleId int NOT NULL,
	ShiftId int         NOT NULL,
	CONSTRAINT ShiftEvents_pk PRIMARY KEY (Id),
	CONSTRAINT ShiftEvents_pk_2 UNIQUE (BeginTime, ShiftScheduleId),
	CONSTRAINT ShiftEvents_ShiftSchedules_Id_fk FOREIGN KEY (ShiftScheduleId) REFERENCES OEE.ShiftSchedules,
	CONSTRAINT ShiftEvents_Shifts_Id_fk FOREIGN KEY (ShiftId) REFERENCES OEE.Shifts
)
go

CREATE TABLE OEE.StateClasses (
	Id int IDENTITY,
	Name varchar(50) NOT NULL,
	CONSTRAINT StateClasses_pk PRIMARY KEY (Id),
	CONSTRAINT StateClasses_pk_2 UNIQUE (Name)
)
go

CREATE TABLE OEE.Equipment (
	Id int IDENTITY,
	Enterprise varchar(50) NOT NULL,
	Site varchar(50)       NOT NULL,
	Area varchar(50)       NOT NULL,
	Line varchar(50)       NOT NULL,
	Cell varchar(50),
	Description varchar(255),
	ShiftScheduleId int,
	StateClassId int,
	Path AS CONCAT([Enterprise], '/', [Site], '/', [Area], '/', [Line],
				   CASE WHEN [Cell] IS NULL THEN '' ELSE CONCAT('/', [Cell]) END),
	CONSTRAINT Equipment_pk PRIMARY KEY (Id),
	CONSTRAINT Equipment_pk_2 UNIQUE (Path),
	CONSTRAINT Equipment_StateClasses_Id_fk FOREIGN KEY (StateClassId) REFERENCES OEE.StateClasses
)
go

CREATE TABLE OEE.Counters (
	Id int IDENTITY,
	EquipmentId int NOT NULL,
	Name int        NOT NULL,
	Type int        NOT NULL,
	Mode int        NOT NULL,
	Value int,
	CONSTRAINT Counters_pk PRIMARY KEY (Id),
	CONSTRAINT Counters_pk_2 UNIQUE (EquipmentId, Name),
	CONSTRAINT Counters_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment
)
go

CREATE TABLE OEE.PerformanceEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	IdealRate float,
	ScheduleRate float,
	CONSTRAINT PerformanceEvents_pk PRIMARY KEY (Id),
	CONSTRAINT PerformanceEvents_pk_2 UNIQUE (BeginTime, EquipmentId),
	CONSTRAINT PerformanceEvents_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment
)
go

CREATE TABLE OEE.States (
	Id int IDENTITY,
	StateClassId int NOT NULL,
	Name varchar(50) NOT NULL,
	Value int        NOT NULL,
	Running bit,
	Slow bit         NOT NULL,
	Waste bit        NOT NULL,
	Recordable bit   NOT NULL,
	CONSTRAINT States_pk PRIMARY KEY (Id),
	CONSTRAINT States_pk_2 UNIQUE (StateClassId, Name),
	CONSTRAINT States_pk_3 UNIQUE (StateClassId, Value),
	CONSTRAINT States_StateClasses_Id_fk FOREIGN KEY (StateClassId) REFERENCES OEE.StateClasses
)
go

CREATE TABLE OEE.StateReasons (
	Id int IDENTITY,
	StateId int      NOT NULL,
	Name varchar(50) NOT NULL,
	Category varchar(50),
	Scheduled bit DEFAULT 0 NOT NULL,
	CONSTRAINT StateReasons_pk PRIMARY KEY (Id),
	CONSTRAINT StateReasons_pk_2 UNIQUE (StateId, Category, Name),
	CONSTRAINT StateReasons_States_Id_fk FOREIGN KEY (StateId) REFERENCES OEE.States,
)
go

CREATE TABLE OEE.StateEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	StateId int,
	ReasonId int,
	ReasonComment varchar(2000),
	CONSTRAINT StateEvents_pk PRIMARY KEY (Id),
	CONSTRAINT StateEvents_pk_2 UNIQUE (BeginTime, EquipmentId),
	CONSTRAINT StateEvents_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment,
	CONSTRAINT StateEvents_StateReasons_Id_fk FOREIGN KEY (ReasonId) REFERENCES OEE.StateReasons,
	CONSTRAINT StateEvents_States_Id_fk FOREIGN KEY (StateId) REFERENCES OEE.States
)
go

CREATE TABLE OEE.EquipmentEvents (
	Id int IDENTITY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	StateEventId int,
	JobEventId int,
	ShiftEventId int,
	PerformanceEventId int,
	CONSTRAINT EquipmentEvents_pk PRIMARY KEY (Id),
	CONSTRAINT EquipmentEvents_uk UNIQUE (EquipmentId, BeginTime),
	CONSTRAINT EquipmentEvents_Equipment_Id_fk FOREIGN KEY (EquipmentId) REFERENCES OEE.Equipment,
	CONSTRAINT EquipmentEvents_JobEvents_Id_fk FOREIGN KEY (JobEventId) REFERENCES OEE.JobEvents,
	CONSTRAINT EquipmentEvents_PerformanceEvents_Id_fk FOREIGN KEY (PerformanceEventId) REFERENCES OEE.PerformanceEvents,
	CONSTRAINT EquipmentEvents_ShiftEvents_Id_fk FOREIGN KEY (ShiftEventId) REFERENCES OEE.ShiftEvents,
	CONSTRAINT EquipmentEvents_StateEvents_Id_fk FOREIGN KEY (StateEventId) REFERENCES OEE.StateEvents
)
go

CREATE TABLE OEE.CounterEvents (
	Id int IDENTITY,
	EquipmentEventId int NOT NULL,
	CounterId int        NOT NULL,
	BeginValue int,
	EndValue int,
	DeltaValue int,
	CONSTRAINT CounterEvents_pk PRIMARY KEY (Id),
	CONSTRAINT CounterEvents_pk_2 UNIQUE (EquipmentEventId, CounterId),
	CONSTRAINT CounterEvents_Counters_Id_fk FOREIGN KEY (CounterId) REFERENCES OEE.Counters,
	CONSTRAINT CounterEvents_EquipmentEvents_Id_fk FOREIGN KEY (EquipmentEventId) REFERENCES OEE.EquipmentEvents
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
	FROM OEE.EquipmentEvents
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
	FROM OEE.JobEvents
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
	FROM OEE.ShiftEvents
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
	FROM OEE.StateEvents
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

    -- Assign the current UTC date time to @beginTime if it's NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME()

    -- Declare various variables to store the relevant data from the last recorded equipment event
    DECLARE
        @equipmentEventId int,
        @stateEventId int,
        @jobEventId int,
        @shiftEventId int,
        @performanceEventId int,
        @lastBeginTime datetime,
        @lastEndTime datetime;

    -- Query the last event for the specified equipment from the EquipmentEvents table
    SELECT TOP (1)
        @equipmentEventId = EE.Id,                -- Event's unique identifier
        @stateEventId = EE.StateEventId,          -- State event associated with the equipment event
        @jobEventId = EE.JobEventId,              -- Job event associated with the equipment event
        @shiftEventId = EE.ShiftEventId,          -- Shift event associated with the equipment event
        @performanceEventId = EE.PerformanceEventId, -- Performance event associated with the equipment event
        @lastBeginTime = EE.BeginTime,                -- Start time of the event
        @lastEndTime = EE.EndTime                     -- End time of the event
    FROM OEE.EquipmentEvents EE
    WHERE EquipmentId = @equipmentId            -- Filter by provided equipmentId
    AND BeginTime <= @beginTime                     -- Ensure to pick an event that started before or at the specified time
    ORDER BY BeginTime DESC;                        -- Sort events based on BeginTime, most recent first

    -- If beginTime matches with a recorded event's begin time, assign the matching event's ID to @eventId and end the procedure
    IF @lastBeginTime  = @beginTime
    BEGIN
        SET @eventId = @equipmentEventId
        RETURN
    END

    -- If the equipment event ID is not NULL, update the EndTime of the event to @beginTime in the EquipmentEvents table
    IF @equipmentEventId IS NOT NULL
    BEGIN
        UPDATE OEE.EquipmentEvents
        SET EndTime = @beginTime
        WHERE Id = @equipmentEventId
    END

    -- Insert a new record in the EquipmentEvents table with the provided and fetched details and assign @beginTime as the BeginTime
    INSERT INTO OEE.EquipmentEvents (
        EquipmentId,
        StateEventId,
        JobEventId,
        ShiftEventId,
        PerformanceEventId,
        BeginTime
    )
    VALUES (
        @equipmentId,
        @stateEventId,
        @jobEventId,
        @shiftEventId,
        @performanceEventId,
        @beginTime
    )

    -- Get the ID of the newly inserted record and assign it to @eventId
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