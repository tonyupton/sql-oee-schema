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
        @lastBeginTime datetime,
        @lastEndTime datetime;

    -- Query the last event for the specified equipment from the EquipmentEvents table
    SELECT TOP (1)
        @equipmentEventId = EE.Id,                -- Event's unique identifier
        @stateEventId = EE.StateEventId,          -- State event associated with the equipment event
        @jobEventId = EE.JobEventId,              -- Job event associated with the equipment event
        @shiftEventId = EE.ShiftEventId,          -- Shift event associated with the equipment event
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
        BeginTime
    )
    VALUES (
        @equipmentId,
        @stateEventId,
        @jobEventId,
        @shiftEventId,
        @beginTime
    )

    -- Get the ID of the newly inserted record and assign it to @eventId
    SET @eventId = SCOPE_IDENTITY()
END
go

