ALTER PROCEDURE [oee].[usp_InsertJobEvent] (
	@equipmentId int,
	@jobId int,
	@beginTime datetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

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
	DECLARE @newJobEventId int
	IF @lastJobId IS NULL
	        OR ( @jobId != ISNULL(@lastJobId, -1)
	        AND @lastJobEventBeginTime < @beginTime)
    BEGIN
        INSERT INTO oee.JobEvents (EquipmentId, JobId, BeginTime)
        VALUES (@equipmentId, @jobId, @beginTime)
        SET @newJobEventId = SCOPE_IDENTITY()
    END

    -- If no new Job Event was inserted then return
    IF @newJobEventId IS NULL RETURN

	-- Select data from last Equipment Event
	DECLARE @lastEquipmentEventId int,
	    @lastStateEventId int,
	    @lastShiftEventId int,
	    @lastPerformanceEventId int,
	    @lastBeginTime datetime,
	    @lastEndTime datetime
    SELECT TOP (1)
        @lastEquipmentEventId = Id,
        @lastStateEventId = StateEventId,
        @lastJobEventId = JobEventId,
        @lastShiftEventId = ShiftEventId,
        @lastPerformanceEventId = PerformanceEventId,
        @lastBeginTime = BeginTime,
        @lastEndTime = EndTime
	FROM EquipmentEvents
	WHERE EquipmentId = @equipmentId
	ORDER BY BeginTime DESC

	-- If last equipment event is after @beginTime then return
	IF @lastBeginTime > @beginTime RETURN

	-- If begin time is the same, just update current event and return
    IF @lastEquipmentEventId IS NOT NULL
            AND @newJobEventId != ISNULL(@lastJobEventId, -1)
            AND @lastBeginTime = @beginTime
    BEGIN
        UPDATE oee.EquipmentEvents
        SET JobEventId = @newJobEventId
        WHERE Id = @lastEquipmentEventId
        RETURN
    END

    INSERT INTO oee.EquipmentEvents (
        EquipmentId,
        StateEventId,
        JobEventId,
        ShiftEventId,
        PerformanceEventId,
        BeginTime
    ) VALUES (
        @equipmentId,
        @lastStateEventId,
        @newJobEventId,
        @lastShiftEventId,
        @lastPerformanceEventId,
        @beginTime
    )

END

GO