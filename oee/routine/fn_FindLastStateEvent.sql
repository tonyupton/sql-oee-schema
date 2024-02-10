
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
	FROM StateEvents
	WHERE EquipmentId = @equipmentId
	AND BeginTime <= @beginTime
	ORDER BY BeginTime DESC

	RETURN @id
END
go

