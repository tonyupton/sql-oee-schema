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

