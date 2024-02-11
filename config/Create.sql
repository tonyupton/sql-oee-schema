SET QUOTED_IDENTIFIER ON

CREATE TABLE OEE.Jobs (
	Id int IDENTITY
		CONSTRAINT Jobs_pk PRIMARY KEY
		CONSTRAINT Jobs_pk_2 UNIQUE,
	Reference varchar(50) NOT NULL
)
go

CREATE TABLE OEE.JobEvents (
	Id int IDENTITY
		CONSTRAINT JobEvents_pk PRIMARY KEY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL,
	JobId int          NOT NULL
		CONSTRAINT JobEvents_Jobs_Id_fk REFERENCES OEE.Jobs,
	CONSTRAINT JobEvents_pk_2 UNIQUE (EquipmentId, BeginTime)
)
go

CREATE TABLE OEE.ShiftSchedules (
	Id int IDENTITY
		CONSTRAINT ShiftSchedules_pk PRIMARY KEY,
	Name varchar(50) NOT NULL
		CONSTRAINT ShiftSchedules_pk_2 UNIQUE
)
go

CREATE TABLE OEE.Shifts (
	Id int IDENTITY
		CONSTRAINT Shifts_pk PRIMARY KEY,
	Name varchar(50) NOT NULL,
	ScheduleId int
		CONSTRAINT Shifts_ShiftSchedules_Id_fk REFERENCES OEE.ShiftSchedules,
	CONSTRAINT Shifts_pk_2 UNIQUE (ScheduleId, Name)
)
go

CREATE TABLE OEE.ShiftEvents (
	Id int IDENTITY
		CONSTRAINT ShiftEvents_pk PRIMARY KEY,
	BeginTime datetime  NOT NULL,
	EndTime datetime,
	ShiftScheduleId int NOT NULL
		CONSTRAINT ShiftEvents_ShiftSchedules_Id_fk REFERENCES OEE.ShiftSchedules,
	ShiftId int         NOT NULL
		CONSTRAINT ShiftEvents_Shifts_Id_fk REFERENCES OEE.Shifts,
	CONSTRAINT ShiftEvents_pk_2 UNIQUE (BeginTime, ShiftScheduleId)
)
go

CREATE TABLE OEE.StateClasses (
	Id int IDENTITY
		CONSTRAINT StateClasses_pk PRIMARY KEY,
	Name varchar(50) NOT NULL
		CONSTRAINT StateClasses_pk_2 UNIQUE
)
go

CREATE TABLE OEE.Equipment (
	Id int IDENTITY
		CONSTRAINT Equipment_pk PRIMARY KEY,
	Enterprise varchar(50) NOT NULL,
	Site varchar(50)       NOT NULL,
	Area varchar(50)       NOT NULL,
	Line varchar(50)       NOT NULL,
	Cell varchar(50),
	Description varchar(255),
	ShiftScheduleId int,
	StateClassId int
		CONSTRAINT Equipment_StateClasses_Id_fk REFERENCES OEE.StateClasses,
	Path AS CONCAT([Enterprise], '/', [Site], '/', [Area], '/', [Line],
				   CASE WHEN [Cell] IS NULL THEN '' ELSE CONCAT('/', [Cell]) END) CONSTRAINT Equipment_pk_2 UNIQUE
)
go

CREATE TABLE OEE.Counters (
	Id int IDENTITY
		CONSTRAINT Counters_pk PRIMARY KEY,
	EquipmentId int NOT NULL
		CONSTRAINT Counters_Equipment_Id_fk REFERENCES OEE.Equipment,
	Name int        NOT NULL,
	Type int        NOT NULL,
	Mode int        NOT NULL,
	Value int,
	CONSTRAINT Counters_pk_2 UNIQUE (EquipmentId, Name)
)
go

CREATE TABLE OEE.PerformanceEvents (
	Id int IDENTITY
		CONSTRAINT PerformanceEvents_pk PRIMARY KEY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL
		CONSTRAINT PerformanceEvents_Equipment_Id_fk REFERENCES OEE.Equipment,
	IdealRate float,
	ScheduleRate float,
	CONSTRAINT PerformanceEvents_pk_2 UNIQUE (BeginTime, EquipmentId)
)
go

CREATE TABLE OEE.States (
	Id int IDENTITY
		CONSTRAINT States_pk PRIMARY KEY,
	StateClassId int NOT NULL
		CONSTRAINT States_StateClasses_Id_fk REFERENCES OEE.StateClasses,
	Name varchar(50) NOT NULL,
	Value int        NOT NULL,
	Running bit,
	Slow bit         NOT NULL,
	Waste bit        NOT NULL,
	Recordable bit   NOT NULL,
	CONSTRAINT States_pk_2 UNIQUE (StateClassId, Name),
	CONSTRAINT States_pk_3 UNIQUE (StateClassId, Value)
)
go

CREATE TABLE OEE.StateReasons (
	Id int IDENTITY
		CONSTRAINT StateReasons_pk PRIMARY KEY,
	StateId int      NOT NULL
		CONSTRAINT StateReasons_States_Id_fk REFERENCES OEE.States,
	Name varchar(50) NOT NULL,
	Category varchar(50),
	Scheduled bit DEFAULT 0 NOT NULL,
	CONSTRAINT StateReasons_pk_2 UNIQUE (StateId, Category, Name)
)
go

CREATE TABLE OEE.StateEvents (
	Id int IDENTITY
		CONSTRAINT StateEvents_pk PRIMARY KEY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL
		CONSTRAINT StateEvents_Equipment_Id_fk REFERENCES OEE.Equipment,
	StateId int
		CONSTRAINT StateEvents_States_Id_fk REFERENCES OEE.States,
	ReasonId int
		CONSTRAINT StateEvents_StateReasons_Id_fk REFERENCES OEE.StateReasons,
	ReasonComment varchar(2000),
	CONSTRAINT StateEvents_pk_2 UNIQUE (BeginTime, EquipmentId)
)
go

CREATE TABLE OEE.EquipmentEvents (
	Id int IDENTITY
		CONSTRAINT EquipmentEvents_pk PRIMARY KEY,
	BeginTime datetime NOT NULL,
	EndTime datetime,
	EquipmentId int    NOT NULL
		CONSTRAINT EquipmentEvents_Equipment_Id_fk REFERENCES OEE.Equipment,
	StateEventId int
		CONSTRAINT EquipmentEvents_StateEvents_Id_fk REFERENCES OEE.StateEvents,
	JobEventId int
		CONSTRAINT EquipmentEvents_JobEvents_Id_fk REFERENCES OEE.JobEvents,
	ShiftEventId int
		CONSTRAINT EquipmentEvents_ShiftEvents_Id_fk REFERENCES OEE.ShiftEvents,
	PerformanceEventId int
		CONSTRAINT EquipmentEvents_PerformanceEvents_Id_fk REFERENCES OEE.PerformanceEvents,
	CONSTRAINT EquipmentEvents_uk UNIQUE (EquipmentId, BeginTime)
)
go

CREATE TABLE OEE.CounterEvents (
	Id int IDENTITY
		CONSTRAINT CounterEvents_pk PRIMARY KEY,
	EquipmentEventId int NOT NULL
		CONSTRAINT CounterEvents_EquipmentEvents_Id_fk REFERENCES OEE.EquipmentEvents,
	CounterId int        NOT NULL
		CONSTRAINT CounterEvents_Counters_Id_fk REFERENCES OEE.Counters,
	BeginValue int,
	EndValue int,
	DeltaValue int,
	CONSTRAINT CounterEvents_pk_2 UNIQUE (EquipmentEventId, CounterId)
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

	-- Validate parameters
	IF @shiftScheduleId IS NULL RETURN
	IF @shiftId IS NULL RETURN

	-- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME()
	SET @shiftEventId = NULL

	-- Find the last recorded Shift Event for given equipment
	DECLARE @lastShiftEventId int
	DECLARE @lastShiftId int
	DECLARE @lastShiftEventBeginTime datetime
	DECLARE @lastShiftEventEndTime datetime
	SELECT TOP (1)
		@lastShiftEventId = Id,
		@lastShiftId = ShiftId,
		@lastShiftEventBeginTime = BeginTime,
		@lastShiftEventEndTime = EndTime
	FROM OEE.ShiftEvents
	WHERE ShiftScheduleId = @shiftScheduleId
	AND BeginTime <= @beginTime
	ORDER BY BeginTime DESC

	-- Terminate previous Shift Event
	IF @lastShiftEventId IS NOT NULL
            AND @shiftId != ISNULL(@lastShiftId, -1)
            AND @lastShiftEventBeginTime < @beginTime
            AND @lastShiftEventEndTime IS NULL
    BEGIN
        UPDATE OEE.ShiftEvents
        SET EndTime = @beginTime
        WHERE Id = @lastShiftEventId
    END

    -- Insert new Shift Event
	IF @lastShiftEventId IS NULL
	        OR (ISNULL(@shiftId, -1) != ISNULL(@lastShiftId, -1)
	        AND @lastShiftEventBeginTime < @beginTime)
    BEGIN
        INSERT INTO OEE.ShiftEvents (ShiftScheduleId, ShiftId, BeginTime)
        VALUES (@shiftScheduleId, @shiftId, @beginTime)
        SET @shiftEventId = SCOPE_IDENTITY()
    END

    -- If no new State Event was inserted then return
    IF @shiftEventId IS NULL RETURN

	-- Select all Equipment that reference this ShiftScheduleId
	DECLARE @cursor CURSOR
	SET @cursor = CURSOR STATIC FOR
		SELECT Id
		FROM OEE.Equipment
		WHERE ShiftScheduleId = @shiftScheduleId

	OPEN @cursor

	WHILE 1 = 1
	BEGIN
		DECLARE @equipmentId int
		DECLARE @equipmentEventId int

		FETCH @cursor INTO @equipmentId

		IF @@fetch_status <> 0 BREAK

		-- Start new Equipment Event
		EXECUTE OEE.usp_BeginEquipmentEvent
			@equipmentId,
			@beginTime,
			@equipmentEventId OUTPUT

		-- Set ShiftEventId on the new EquipmentEvent to the new ShiftEventID
		UPDATE OEE.EquipmentEvents
		SET ShiftEventId = @shiftEventId
		WHERE Id = @equipmentEventId
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