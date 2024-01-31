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
	FROM oee.StateEvents
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
        UPDATE oee.StateEvents
        SET EndTime = @beginTime
        WHERE Id = @lastStateEventId
    END

    -- Insert new State Event
	IF @lastStateEventId IS NULL
	        OR ( @stateId != ISNULL(@lastStateId, -1)
	        AND @lastStateEventBeginTime < @beginTime)
    BEGIN
        INSERT INTO oee.StateEvents (EquipmentId, StateId, BeginTime)
        VALUES (@equipmentId, @stateId, @beginTime)
        SET @stateEventId = SCOPE_IDENTITY()
    END


	-- If no new State Event was inserted then return
    IF @stateEventId IS NULL RETURN

	-- Start new Equipment Event
	EXECUTE oee.usp_BeginEquipmentEvent
            @equipmentId,
            @beginTime,
            @equipmentEventId OUTPUT

	-- Set StateEventId on the new EquipmentEvent to the new StateEventID
    UPDATE oee.EquipmentEvents
    SET StateEventId = @stateEventId
    WHERE Id = @equipmentEventId
END
go

