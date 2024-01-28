CREATE PROCEDURE [oee].[usp_InsertShiftEvent] (
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

