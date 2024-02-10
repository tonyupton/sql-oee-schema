
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

