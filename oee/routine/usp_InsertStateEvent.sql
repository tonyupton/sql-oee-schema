CREATE PROCEDURE [oee].[usp_InsertStateEvent] (
	@equipmentId int,
	@stateId int,
	@timestamp datetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @timestamp IS NULL SET @timestamp = SYSUTCDATETIME ( )

	DECLARE @currentStateEventId int,
		@currentStateEventBeginTime datetime,
		@currentStateEventEndTime datetime,
		@currentStateId int

	SELECT TOP (1)
		@currentStateEventId = Id,
		@currentStateEventBeginTime = BeginTime,
		@currentStateEventEndTime = EndTime,
		@currentStateId = StateId
	FROM oee.StateEvents
	WHERE EquipmentId = @equipmentId 
	AND BeginTime <= @timestamp
	AND (EndTime IS NULL OR EndTime > @timestamp)
	ORDER BY BeginTime DESC

	IF @currentStateEventBeginTime = @timestamp
	BEGIN
		--Update StateId if BeginTime = @timestamp
		UPDATE oee.StateEvents
			SET StateId = @stateId
		WHERE Id = @currentStateEventId
	END
	ELSE IF @currentStateId != @stateId OR @currentStateId IS NULL
	BEGIN
		--Terminate current EquipmentStateEvent
		UPDATE oee.StateEvents
			SET EndTime = @timestamp
		WHERE Id = @currentStateEventId

		--INSERT new State Event
		INSERT INTO oee.StateEvents (
			EquipmentId,
			BeginTime,
			StateId
		)
		VALUES (
			@equipmentId,
			@timestamp,
			@stateId
		)
		DECLARE @insertedStateEventId int = SCOPE_IDENTITY ( )

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
		AND events.BeginTime <= @timestamp
		ORDER BY events.BeginTime DESC

		DECLARE @currentEquipmentEventId int = (SELECT Id FROM @currentEquipmentEvents)

		-- UPDATE StateEventId in EquipmentEvents where BeginTime = @timestamp
		UPDATE oee.EquipmentEvents
		SET StateEventId = @insertedStateEventId
		FROM oee.EquipmentEvents events
		WHERE events.Id = @currentEquipmentEventId AND events.BeginTime = @timestamp

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
		WHERE events.Id = @currentEquipmentEventId AND events.BeginTime < @timestamp

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
			@timestamp
		FROM @terminatedEquipmentEvents equipmentEvents
	END
END
go

