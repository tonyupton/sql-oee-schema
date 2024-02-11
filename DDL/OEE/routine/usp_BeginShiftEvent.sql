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

