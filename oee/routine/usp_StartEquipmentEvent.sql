CREATE PROCEDURE [oee].[usp_StartEquipmentEvent] (
	@equipmentId int,
	@beginTime datetime = NULL,
    @newEventId int OUTPUT
)
AS
BEGIN

    -- Set @beginTime to current time if NULL
	IF @beginTime IS NULL SET @beginTime = SYSUTCDATETIME()

    DECLARE @lastEventId int = oee.fn_FindLastEquipmentEvent(@equipmentId, @beginTime)

    DECLARE @lastEventTime datetime = (SELECT BeginTime FROM oee.EquipmentEvents WHERE Id = @lastEventId)

    IF @lastEventTime = @beginTime
    BEGIN
        SET @newEventId = @lastEventId
        RETURN
    END

    INSERT INTO oee.EquipmentEvents
    (EquipmentId, StateEventId, JobEventId, ShiftEventId, PerformanceEventId, BeginTime)
    SELECT TOP (1)
        @equipmentId,
        StateEventId,
        JobEventId,
        ShiftEventId,
        PerformanceEventId,
        BeginTime
	FROM EquipmentEvents
	WHERE EquipmentId = @equipmentId
    AND Id = @lastEventId

    SET @newEventId = SCOPE_IDENTITY()
END
go

